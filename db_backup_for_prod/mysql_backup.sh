#!/bin/bash
set -x
set -e

process_args() {
    while [ $# -gt 1 ]
    do
        key="$1"
        case $key in
            -bh|--backup-home)
                backup_path="$2"
                shift #past argument
            ;;
            -dl|--db-list)
                db_list="$2"
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
            -h|--mysql-host)
                mysql_host="$2"
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
            -p|--mysql-port)
                mysql_port="$2"
                shift # past argument
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
        `mysqldump --host $mysql_host --port=$mysql_port --databases $db -u $db_user --password="$db_password" > $backup_path/$backup_directory/$db.sql` || true
    done
    echo "Databases dump for $service has been taken"

}



mysql_backup() {

    backup_path=$backup_path/db_backups/mysql
    mkdir -p $backup_path/$backup_directory

    echo "mysql backup directory" $backup_path/$backup_directory
	backup

}

# Main script starts here
if [ $# -ne 16 ]
then
    echo "usage: mysql_backup.sh --backup-home <backup_directory> --db-list <db_list> --stack-name <stack_name> --db-user <db_user> --db-password <db_password> --mysql-host <mysql_host> --mysql-port <mysql_port> --backup-directory <backup_directory> --service-name <service>"
    exit 1
fi

process_args $@
mysql_backup

