#!/bin/bash

START_FILE="start_10.csv"
DEPLOYMENT_FILE="deployment_10.csv"
END_FILE="end_10.csv"
DELETE_FILE="delete_10.csv"
INTERVAL=5
MAX_TIME_START=60
MAX_TIME_DEPLOY=120
MAX_TIME_END=60
MAX_TIME_DELETE=60

echo "timestamp,cpu_usage_percent,mem_usage_percent,disk_usage_percent,read_disk,write_disk" > "$START_FILE"
echo "timestamp,cpu_usage_percent,mem_usage_percent,disk_usage_percent,read_disk,write_disk" > "$DEPLOYMENT_FILE"
echo "timestamp,cpu_usage_percent,mem_usage_percent,disk_usage_percent,read_disk,write_disk" > "$END_FILE"
echo "timestamp,cpu_usage_percent,mem_usage_percent,disk_usage_percent,read_disk,write_disk" > "$DELETE_FILE"

echo "[INFO] Monitoring system resources every $INTERVAL seconds..."

collect_metrics() {
    local duration=$1
    local output_file=$2
    local start_action=$3
    local delay_trigger=$4
    local trigger_done=false
    local SECONDS_ELAPSED=0

    while [ $SECONDS_ELAPSED -le $duration ]; do
        timestamp="${SECONDS_ELAPSED}s"

        if [ $SECONDS_ELAPSED -eq $delay_trigger ] && [ "$trigger_done" = false ]; then
            echo "[INFO] Executing triggered action at $SECONDS_ELAPSED seconds..."
            eval "$start_action" &
            trigger_done=true
        fi

        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{printf "%.1f", 100 - $8}')
        mem_used=$(free -m | awk '/Mem:/ {print $3}')
        mem_total=$(free -m | awk '/Mem:/ {print $2}')
        mem_usage_percent=$(awk "BEGIN {printf \"%.1f\", ($mem_used/$mem_total)*100}")

        io_stats=$(dstat --disk-util -dD total 1 1 | tail -n 1)
        current_disk_utilisation=$(echo "$io_stats" | awk '{gsub(/[^0-9.]/, "", $1); print $1}')
        current_read=$(echo "$io_stats" | awk '{gsub(/[^0-9.]/, "", $2); print $2}')
        current_write=$(echo "$io_stats" | awk '{gsub(/[^0-9.]/, "", $3); print $3}')

        echo "$timestamp,$cpu_usage,$mem_usage_percent,$current_disk_utilisation,$current_read,$current_write" >> "$output_file"

        sleep $INTERVAL
        SECONDS_ELAPSED=$((SECONDS_ELAPSED + INTERVAL))
    done
}

trap "echo -e '\n[INFO] Stopping resource monitor.'; exit 0" SIGINT

# 1. Monitor minikube start
collect_metrics "$MAX_TIME_START" "$START_FILE" "minikube start" 10
echo "Start deployment"
# 2. Monitor deployments
DEPLOY_COMMANDS="
minikube kubectl -- apply -f server/server-deployment.yml
minikube kubectl -- apply -f consumer/consumer-deployment.yml
minikube kubectl -- apply -f producer/producer-deployment.yml
minikube kubectl -- apply -f export_to_csv/export-csv-deployment.yml
minikube kubectl -- apply -f display_graph/display-graph-deployment.yml
minikube kubectl -- apply -f get_min_max_avg/get-values-deployment.yml
helm install sensor-db-postgresql bitnami/postgresql --set auth.postgresPassword=postgres --set volumePermissions.enabled=true
helm install rabbitmq bitnami/rabbitmq --set auth.username=guest --set auth.password=guest --set auth.forcePassword=true --set rabbitmq.extraConfiguration='loopback_users = none'
"
collect_metrics "$MAX_TIME_DEPLOY" "$DEPLOYMENT_FILE" "$DEPLOY_COMMANDS" 10

echo "Stop"
collect_metrics "$MAX_TIME_END" "$END_FILE" "minikube stop" 10

echo "Delete"
collect_metrics "$MAX_TIME_DELETE" "$DELETE_FILE" "minikube delete" 10

echo "[INFO] All metrics collected successfully."



    # start=curr_time
    # kubectl apply -f server/server-deployment.yml
    # kubectl apply -f consumer/consumer-deployment.yml
    # kubectl apply -f producer/producer-deployment.yml
    # kubectl apply -f export_to_csv/export-csv-deployment.yml
    # kubectl apply -f display_graph/display-graph-deployment.yml
    # kubectl apply -f get_min_max_avg/get-values-deployment.yml
    # helm install sensor-db-postgresql bitnami/postgresql --set auth.postgresPassword=postgres --set volumePermissions.enabled=true
    # helm install rabbitmq bitnami/rabbitmq   --set auth.username=guest   --set auth.password=guest   --set auth.forcePassword=true   --set rabbitmq.extraConfiguration="loopback_users = none"
    # end=curr_time
    # elapsed_time= end-start
    # echo "$elapsed_time" >> DEPLOYMENT_TIME