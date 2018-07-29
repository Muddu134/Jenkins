#!/bin/bash

set -x


process_args() {
    while [ $# -gt 1 ]
    do
        key="$1"
        case $key in
            -mi | --main-ip)
                main_host_ip="$2"
                shift # past argument
            ;;
            -ri | --redfort-ip)
                redfort_host_ip="$2"
                shift # past argument
            ;;
            -wi | --worker-ip)
                worker_host_ip="$2"
                shift # past argument
            ;;
            -ali | --asset_lookup-ip)
                asset_lookup_host_ip="$2"
                shift # past argument
            ;;
            -ami | --asset_manager-ip)
                asset_manager_host_ip="$2"
                shift # past argument
            ;;
            -rpi | --reporting-ip)
                reporting_host_ip="$2"
                shift # past argument
            ;;
            -hi | --hpcs-ip)
                hpcs_host_ip="$2"
                shift # past argument
            ;;
            -ii | --integration-ip)
                integration_host_ip="$2"
                shift # past argument
            ;;
            -u | --username)
                username="$2"
                shift #past argument
            ;;
            *) echo "Invalid option $1" >&2
            exit 1
            ;;
        esac
        shift # past argument or value
    done

}

#logs_folder="/opt/mount1/portico/prod_logs"
#install_dir="/opt/mount1/portico"
logs_folder="/home/alam/logs_folder"
install_dir="/home/alam/new_remote_server"
mkdir -p $logs_folder


backup_main_logs() {
mkdir -p $logs_folder/main
    scp -r  $username@$main_host_ip:$install_dir/main/runtime $logs_folder/main/
    scp -r  $username@$main_host_ip:$install_dir/main/logs $logs_folder/main/
}

backup_redfort_logs() {
mkdir -p $logs_folder/redfort
    scp -r  $username@$redfort_host_ip:$install_dir/redfort/runtime $logs_folder/redfort/
    scp -r  $username@$redfort_host_ip:$install_dir/redfort/logs $logs_folder/redfort/
}

backup_worker_logs() {
mkdir -p $logs_folder/worker
    scp -r  $username@$worker_host_ip:$install_dir/main/worker/runtime $logs_folder/worker/
}

backup_asset_lookup_logs() {
mkdir -p $logs_folder/asset_lookup
    scp -r  $username@$asset_lookup_host_ip:$install_dir/asset_lookup/runtime $logs_folder/asset_lookup/
    scp -r  $username@$asset_lookup_host_ip:$install_dir/asset_lookup/logs $logs_folder/asset_lookup/
}

backup_asset_manager_logs() {
mkdir -p $logs_folder/asset_manager
    scp -r  $username@$asset_manager_host_ip:$install_dir/asset_manager/runtime $logs_folder/asset_manager/
    scp -r  $username@$asset_manager_host_ip:$install_dir/asset_manager/logs $logs_folder/asset_manager/
}

backup_reporting_logs() {
mkdir -p $logs_folder/reporting
    scp -r  $username@$reporting_host_ip:$install_dir/reporting/runtime $logs_folder/reporting/
}

backup_hpcs_logs() {
mkdir -p $logs_folder/hpcs
    scp -r  $username@$hpcs_host_ip:$install_dir/hpcs/runtime $logs_folder/hpcs/
}

backup_integration_logs() {
mkdir -p $logs_folder/integration
    scp -r  $username@$integration_host_ip:$install_dir/integration/runtime $logs_folder/integration/
}

if [ $# -ne 18 ]
then
    echo "Usage: "
    exit 1
fi
process_args $@
backup_main_logs
backup_redfort_logs
backup_worker_logs
backup_asset_lookup_logs
backup_asset_manager_logs
backup_hpcs_logs
backup_integration_logs
backup_reporting_logs
