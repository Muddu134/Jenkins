#!/bin/bash
set -x
set -e

process_args() {
    while [ $# -gt 1 ]
    do
        key="$1"
        case $key in
            -p|--mongo-port)
                mongo_port="$2"
                shift # past argument
            ;;
            -h|--mongo-host-ip)
                target_ip="$2"
                shift #past argument
            ;;
            -d|--backup-home)
                backup_path="$2"
                shift #past argument
            ;;
            -da|--db-auth-enabled)
                db_auth_enabled="$2"
                shift #past argument
            ;;
            -du|--db-user)
                db_user="$2"
                shift #past argument
            ;;
            -dp|--db-password)
                db_password="$2"
                shift #past argument
            ;;
            -ad|--auth-db)
                auth_db_name="$2"
                shift #past argument
            ;;
            -dl|--db-list)
                db_list="$2"
                shift #past argument
            ;;
            -bd|--backup-directory)
                backup_directory="$2"
                shift #past argument
            ;;
            -sn|--service-name)
                service="$2"
                shift #past argument
            ;;
            *) echo "Invalid option $1" >&2
            exit 1
            ;;
        esac
        shift #past argument
    done
}


backup() {
    echo "### Taking backup for $service service ###"
    for db in $(echo $db_list | sed "s/,/ /g")
    do
        echo "Taking dump of database: $db"
        mongodump --port $mongo_port --host $target_ip --out $backup_path/$backup_directory --db $db $admin_auth
    done
    echo "Databases dump for $service has been taken"

}


mongo_backup() {

    if [ $db_auth_enabled = "true" ]
    then
        admin_auth="-u $db_user -p $db_password --authenticationDatabase $auth_db_name"
        echo "Using authentication for Mongo"
    else
        admin_auth=""
        echo "not using authentication ---------"
    fi

    backup_path=$backup_path/db_backups/mongodb
    mkdir -p $backup_path/$backup_directory

    echo "mongodb backup directory" $backup_path/$backup_directory
	backup

}


# Main script starts here
if [ $# -ne 14 ] && [ $# -ne 20 ]
then
    echo "usage: mongo_backup.sh --mongo-port <mongodb_port> --mongo-host-ip <target_ip> --backup-home <backup_home> --db-list <db_list>
    --db-auth-enabled <db_auth_enabled> --db-user <db_user> --db-password <db_password> --auth-db <auth_db_name> --backup-directory <backup_directory> --service-name <service>"
    exit 1
fi

process_args $@
mongo_backup

