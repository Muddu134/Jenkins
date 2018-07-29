#!/bin/bash

set -e

## Set variables
readonly EMAIL_ID=""

validate_args() {
    if [ -z $backup_host_ip ] || [ -z $backup_host_username ] || [ -z $mongo_host_ip ] || [ -z $mongo_host_username ] || [ -z $required_days_of_backup ] || [ -z $mongodb_port ] || [ -z $environment_name ] || [ -z $backup_home  ]
    then
        echo "Usage: mongodb_backup_cron.sh --backup_ip <backup_host_ip> --backup_username <backup_host_username> --mongo_ip <mongo_host_ip> --mongo_username <mongo_host_username> --backup_days_required <required_days_of_backup> --mongo_port <mongodb_port> --env_name <environment_name> --backup_home <backup_home>"
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
            -bi | --backup_ip)
                backup_host_ip=$2
                shift # past argument
            ;;
            -bu | --backup_username)
                backup_host_username=$2
                shift #past argument
            ;;
            -mi | --mongo_ip)
                mongo_host_ip=$2
                shift #past argument
            ;;
            -mu | --mongo_username)
                mongo_host_username=$2
                shift #past argument
            ;;
            -bdr | --backup_days_required)
                required_days_of_backup=$2
                shift #past argument
            ;;
            -mp | --mongo_port)
                mongodb_port=$2
                shift #past argument
            ;;
            -env | --env_name)
                environment_name=$2
                shift #past argument
            ;;
            -bh | --backup_home)
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
    ssh -l $backup_host_username $backup_host_ip "mkdir -p $backup_dir"
    ssh -l $backup_host_username $backup_host_ip "mkdir -p $backup_dir/$current_month\_$current_year"

    ssh -l $mongo_host_username $mongo_host_ip "mkdir -p $backup_home"
    #copying the backup script to mongo host since taking mongodump from remote server gives rise to permission issues.
    scp /opt/mount2/scripts/mongodb_backup.sh $mongo_host_username@$mongo_host_ip:$backup_home/mongodb_backup.sh
    scp /opt/mount2/scripts/purge_backup.sh $mongo_host_username@$mongo_host_ip:$backup_home/purge_backup.sh
    scp /opt/mount2/scripts/purge_backup.sh $backup_host_username@$backup_host_ip:$backup_home/purge_backup.sh
    ssh -l $mongo_host_username $mongo_host_ip "bash $backup_home/mongodb_backup.sh --backup_ip $backup_host_ip --backup_username $backup_host_username --mongo_ip $mongo_host_ip --mongo_username $mongo_host_username --backup_days_required $required_days_of_backup --mongo_port $mongodb_port --backup_home $backup_home --env $environment_name"

    if [ $? -ne 0 ]; then
        mail -s "Unable to begin backup process for $mongo_host_ip" $EMAIL_ID < /dev/null
        exit
    fi
}

copy_dump() {
    ##scp it to backup server
    cmd_status=""
    echo "copying dump...."
    ssh -l $mongo_host_username $mongo_host_ip "ssh-keyscan -H $backup_host_ip >> ~/.ssh/known_hosts"
    cmd_status=`scp $mongo_host_username@$mongo_host_ip:/$backup_home/mongo_backup/backup.tar.gz $backup_host_username@$backup_host_ip:$backup_dir/$date_stamp.tar.gz`

    if [ $? -ne 0 ]; then
        mail -s "Unable to scp dump from $mongo_host_ip to $backup_host_ip:$backup_dir/$date_stamp using port 22." $EMAIL_ID < /dev/null
        exit
    else
        echo "Copied dump to backup server in directory $backup_host_ip:$backup_dir/$date_stamp."
        echo "Mongo Backup process completed successfully."
    fi


if [ "$current_day" == 07 ] || [ "$current_day" == 14 ] || [ "$current_day" == 21 ] || [ "$current_day" == 28 ] ; then
       
    ssh -l $backup_host_username $backup_host_ip "cp $backup_dir/$date_stamp.tar.gz $backup_dir/$current_month\_$current_year/"
fi


}

process_args $@
backup_dir="$backup_home/mongo_backup/$environment_name"
begin_backup_process
copy_dump
ssh -l $backup_host_username $backup_host_ip "bash $backup_home/purge_backup.sh --server backup_server --dir $backup_dir --backup_days_required $required_days_of_backup"
