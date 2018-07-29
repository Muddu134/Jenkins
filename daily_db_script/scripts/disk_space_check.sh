#!/bin/bash

set -e
##
#Script to check the disk space usage of home folder and mount1 folder
##
readonly EMAIL_ID=""
readonly VAL=100
readonly list_folders="/opt/mount1 /home"

process_args() {
    while [ $# -gt 1 ]
    do
        key="$1"
        case $key in
            -env | --env_name)
                environment_name=$2
                shift #past argument
            ;;
            -min | --min_space)
                min_space=$2
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

validate_args() {
    if [ -z "$environment_name" ] || [ -z "$min_space" ]
    then
        echo "Usage : disk_space_check.sh --env_name <environment_name> --min_space <min_space>"
        exit 1
    fi
}

disk_space_check() {
    for folder in $list_folders; do
        available_space=`expr $VAL - $(df $folder | grep -oP '\d{1,2}%' | cut -d '%' -f 1)`
        if [ "$available_space" -lt $min_space ]; then
            mail -s "Available space in $folder folder in $environment_name is below $min_space%. Please check!" $EMAIL_ID </dev/null
            exit
        fi
    done
}

process_args $@
disk_space_check $environment_name $min_space
