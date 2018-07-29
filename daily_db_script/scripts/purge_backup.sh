#!/bin/bash

set -e

validate_args() {
    if [ -z $server_name ] || [ -z $backup_dir ] || [ -z $required_days_of_backup ]
    then
        echo "Usage: purge_backup.sh --server <server_name> --dir <backup_directory> --backup_days_required <required_days_of_backup>"
    fi
}

process_args() {
    while [ $# -gt 1 ]
    do
        key=$1
        case $key in
            --server)
                server_name=$2
                shift # past argument
            ;;
            --dir)
                backup_dir=$2
                shift #past argument
            ;;
            -backup | --backup_days_required)
                required_days_of_backup=$2
                shift #past argument
            ;;
            *) echo "Invalid option $1" >&2
            exit 1
            ;;
        esac
        shift # past argument or value
    done
    validate_args
}

purge_backup() {
    backup_count=$(ls $backup_dir | sort | wc -l)
    echo "Previous number of backups on $server_name : $backup_count"

    # if number of database backups more than $required_days_of_backup remove them
    while [ $backup_count -gt $required_days_of_backup ]
    do
        old_backup=$(ls $backup_dir | sort | head -n 1)
        echo "$old_backup will be deleted"
        rm -rf $backup_dir/$old_backup
        backup_count=$(ls $backup_dir | sort | wc -l)
        echo "Current number of backups on $server_name: $backup_count"
    done

    if [ $backup_count -gt $required_days_of_backup ]; then
        echo "Backup beyond $required_days_of_backup days on the $server_name has been deleted"
    fi
}

process_args $@
purge_backup $server_name $backup_dir $required_days_of_backup


