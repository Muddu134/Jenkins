#!/bin/bash

set -e

##
# Script to take mongo backup using mongodump and store it in Backup Server
##

## Set variables
today_date=`date +"%d/%b/%g %r"`
date_stamp=`date +"%m_%d_%Y_%H_%M_%S"`
current_month=`date +"%m"`
current_day=`date +"%d"`
current_year=`date +"%Y"`
MONGO_BIN_PATH="/usr/bin"
TMP_DIR="/opt/mount2"

readonly EMAIL_ID=""

validate_args() {
    if [ -z $backup_host_ip ] || [ -z $backup_host_username ] || [ -z $mongo_host_ip ] || [ -z $mongo_host_username ] || [ -z $required_days_of_backup ] || [ -z $mongodb_port ] || [ -z $backup_home ]
    then
        echo "Usage: mongodb_backup.sh --backup_ip <backup_host_ip> --backup_username <backup_host_username> --mongo_ip <mongo_host_ip> --mongo_username <mongo_host_username> --backup_days_required <required_days_of_backup> --mongo_port <mongodb_port> --backup_home <backup_home> --env <env>"
        exit 1
    fi
}

process_args() {
    while [ $# -gt 1 ]
    do
        key="$1"
        case $key in
            -bi | --backup_ip)
                backup_host_ip="$2"
                shift # past argument
            ;;
            -bu | --backup_username)
                backup_host_username="$2"
                shift #past argument
            ;;
            -mi | --mongo_ip)
                mongo_host_ip="$2"
                shift #past argument
            ;;
            -mu | --mongo_username)
                mongo_host_username="$2"
                shift #past argument
            ;;
            -bdr | --backup_days_required)
                required_days_of_backup="$2"
                shift #past argument
            ;;
            -mp | --mongo_port)
                mongodb_port="$2"
                shift #past argument
            ;;
            -bh | --backup_home)
                backup_home="$2"
                shift #past argument
            ;;
            -env | --env)
                env="$2"
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

log_message() {
    current_time=`date +"%r"`
    echo -e "$current_time: $1" >>$log_file
}

initialize_variables() {
    cd $backup_home
    if [ ! -d mongo_backup/databases ]; then
        mkdir -p mongo_backup/databases
    fi
    cd mongo_backup
    local_dump_dir="$backup_home/mongo_backup/databases"
    log_file="$backup_home/mongo_backup/mongo-backup.log"
    log_message "Mongo Backup Status on $today_date."

if [ $env == 'dev' ]
then
  password='Benjo81$dev'
elif [ $env == 'staging' ]
then
  password='Benjo16$staging9'
elif [ $env == 'production' ]
then
  password='Benjo10$prod0'
elif [ $env == 'awsHP_Prod' ]
then
  password='Benjo25$awshpprod5'
fi
}

#Function takes dump of the mongodb database on the mongodb host
dump_mongo_db() {
    cmd_status=""
    cmd_status=`$MONGO_BIN_PATH/mongodump --out ./databases/$date_stamp --host $mongo_host_ip --port $mongodb_port -u admin -p $password --authenticationDatabase admin`
    if [ $? -ne 0 ]; then
        log_message "There is an issue while trying to take dump in $mongo_host_ip. Aborting dump process, please check!"
        mail -s "There is an issue while trying to take dump in $mongo_host_ip. Aborting dump process, please check!" $EMAIL_ID </dev/null
        exit
    else
        echo "Mongodump taken successfully"
    fi

    if [ ! -d ./databases/$current_month\_$current_year ]; then
        mkdir -p ./databases/$current_month\_$current_year
    fi


if [ "$current_day" == 07 ] || [ "$current_day" == 14 ] || [ "$current_day" == 21 ] || [ "$current_day" == 28 ] ; then
       cp -r ./databases/$date_stamp ./databases/$current_month\_$current_year/$date_stamp
fi

}

calculate_backup_size() {
    backup_size=$(du -sh $local_dump_dir/$date_stamp | awk '{ print $1 }')
    log_message "Mongodump command completed. Backup size is $backup_size.\n \n"
}

create_directory() {
    if [ ! -d $TMP_DIR/mongo_backup ]; then
        mkdir $TMP_DIR/mongo_backup
    fi
}

#Compress the dump taken using tar
compress_dump() {
    tar_file_path="/opt/mount2/mongo_backup/backup.tar.gz"
    if [ -f $tar_file_path ]
    then
        rm $tar_file_path
    fi
    cd $local_dump_dir/$date_stamp/
    ## create tar file
    tar -czf $tar_file_path *
    echo "Backup taken in $local_dump_dir"
}

process_args $@
initialize_variables
dump_mongo_db
calculate_backup_size
create_directory
compress_dump
sh $backup_home/purge_backup.sh --server mongo_host --dir $local_dump_dir --backup_days_required $required_days_of_backup
