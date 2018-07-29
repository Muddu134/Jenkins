#!/bin/bash
set -x
set -e
date_stamp=`date +"%m_%d_%Y_%H_%M_%S"`
stack="hp-prod"
backup_home="/opt/mount1"

mongo_backup() {
cd $backup_home/scripts
backup_directory="full_"$stack"_"$date_stamp
db_list=`mongo -u admin -p 'p2pRaw#t' --authenticationDatabase admin --eval "db.getMongo().getDBNames()" | grep -oP '"\K[a-z0-9][^"]+' | tr '\n' ','| sed 's/admin,//' | sed 's/\(.*\),/\1\n/'`
echo $db_list
bash mongo_backup.sh -p 27017 -h localhost -d $backup_home -da true -du admin -dp 'p2pRaw#t' -ad admin -dl $db_list -bd $backup_directory -sn MongoDB
compress_dump mongodb
}

mysql_backup() {
cd $backup_home/scripts
backup_directory="red_fort_"$stack"_"$date_stamp
db_list="red_fort"
echo $db_list
bash mysql_backup.sh -p 3606 -h localhost -bh $backup_home -du red_fort -dp 'ITT@123456' -dl $db_list -bd $backup_directory -sn Mysql
compress_dump mysql
}

compress_dump() {
db=$1
cd $backup_home/db_backups/$db
tar cvzf $backup_directory.tar.gz $backup_directory/ --remove-files
}


mongo_backup
mysql_backup

