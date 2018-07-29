#!/bin/bash

set -e

## Set variables
readonly EMAIL_ID=""

validate_args() {
    if [ -z $db_name ] ||  [ -z $db_password ] || [ -z $db_host_ip ] || [ -z $db_user ] || [ -z $required_days_of_backup ] || [ -z $db_port ] || [ -z $environment_name ] || [ -z $backup_home  ]
    then
        echo "Usage: mongodb_backup_cron.sh --db-ip <db_host_ip> --db-user <db_user> --db-password <db_password> --db-name <db_name> --backup-days-required <required_days_of_backup> --db-port <mongodb_port> --env-name <environment_name> --backup-home <backup_home>"
        exit 1
    fi
}

process_args() {
    if [ $# -eq 16 ]
    then
        backup_home=$16
    fi

    while [ $# -gt 1 ]
    do
        key=$1
        case $key in
            -di | --db-ip)
                db_host_ip=$2
                shift #past argument
            ;;
            -du | --db-user)
                db_user=$2
                shift #past argument
            ;;
            -dp | --db-password)
                db_password=$2
                shift #past argument
            ;;
            -dn | --db-name)
                db_name=$2
                shift #past argument
            ;;
            -bdr | --backup-days-required)
                required_days_of_backup=$2
                shift #past argument
            ;;
            -dpo | --db-port)
                db_port=$2
                shift #past argument
            ;;
            -env | --env-name)
                environment_name=$2
                shift #past argument
            ;;
            -bh | --backup-home)
                backup_home=$2
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

backup_home="/opt/mount2"
date_stamp=`date +"%m_%d_%Y_%H_%M_%S"`
current_month=`date +"%m"`
current_day=`date +"%d"`
current_year=`date +"%Y"`
log_file="$backup_home/mongo_backup/mongo-backup.log"


begin_backup_process() {
    mkdir -p $backup_dir
    mkdir -p $backup_dir/$current_month\_$current_year
    cd $backup_home
    if [ ! -d mongo_backup/$environment_name ]; then
        mkdir -p mongo_backup/$environment_name
    fi
    cd mongo_backup/$environment_name
    cmd_status=""
    cmd_status=`mongodump --host $db_host_ip --port $db_port --out $backup_dir/$date_stamp -u $db_user -p $db_password --authenticationDatabase admin`

    if [ $? -ne 0 ]; then
        mail -s "Unable to begin backup process for $db_host_ip" $EMAIL_ID < /dev/null
        exit
    fi
}

#Compress the dump taken using tar
compress_dump() {
    tar_file_path="$backup_dir/$date_stamp.tar.gz"

    cd  $backup_dir/
    ## create tar file
    tar -czf $tar_file_path $date_stamp --remove-files
    echo "Backup taken in $backup_dir"
    if [ "$current_day" == 07 ] || [ "$current_day" == 14 ] || [ "$current_day" == 21 ] || [ "$current_day" == 28 ] ; then

        mv $backup_dir/$date_stamp.tar.gz $backup_dir/$current_month\_$current_year/
    fi

}


process_args $@
backup_dir="$backup_home/mongo_backup/$environment_name"
begin_backup_process
compress_dump
bash $backup_home/scripts/purge_backup.sh --server backup_server --dir $backup_dir --backup_days_required $required_days_of_backup

