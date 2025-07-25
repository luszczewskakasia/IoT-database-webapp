#!/bin/bash

NUM_ITERATIONS=2

INTERVAL=5
MAX_TIME_START=60
MAX_TIME_DEPLOY=300
MAX_TIME_END=60
MAX_TIME_DELETE=60

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
            # echo "[INFO] Executing triggered action at $SECONDS_ELAPSED seconds..."
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

trap "echo -e '\n stop'; exit 0" SIGINT




for i in $(seq 1 $NUM_ITERATIONS); do
    START_FILE="start_$i.csv"
    DEPLOYMENT_FILE="deployment_$i.csv"
    END_FILE="end_$i.csv"
    DELETE_FILE="delete_$i.csv"
    echo "timestamp,cpu_usage_percent,mem_usage_percent,disk_usage_percent,read_disk,write_disk" > "$START_FILE"
    echo "timestamp,cpu_usage_percent,mem_usage_percent,disk_usage_percent,read_disk,write_disk" > "$DEPLOYMENT_FILE"
    echo "timestamp,cpu_usage_percent,mem_usage_percent,disk_usage_percent,read_disk,write_disk" > "$END_FILE"
    echo "timestamp,cpu_usage_percent,mem_usage_percent,disk_usage_percent,read_disk,write_disk" > "$DELETE_FILE"
    echo "iteration $i"
    collect_metrics "$MAX_TIME_START" "$START_FILE" "curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE='644' INSTALL_K3S_EXEC='server --disable traefik' sh -s - --node-name k3s-master" 10
    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
    sudo chown $USER:$USER ~/.kube/config  
    cat mirror.sh | sudo tee /etc/rancher/k3s/registries.yaml
    sudo systemctl restart k3s
    echo "Start deployment"
    DEPLOY_COMMANDS="
    helm install sensor-db-postgresql bitnami/postgresql --set auth.postgresPassword=postgres --set volumePermissions.enabled=true --version 16.7.14
    helm install rabbitmq bitnami/rabbitmq --set auth.username=guest --set auth.password=guest --set auth.forcePassword=true --set rabbitmq.extraConfiguration='loopback_users = none'
    helm install ingress ingress-nginx/ingress-nginx --set controller.service.nodePorts.http=31145
    kubectl apply -f server/server-deployment.yml
    kubectl apply -f consumer/consumer-deployment.yml
    kubectl apply -f producer/producer-deployment.yml
    kubectl apply -f export_to_csv/export-csv-deployment.yml
    kubectl apply -f display_graph/display-graph-deployment.yml
    kubectl apply -f get_min_max_avg/get-values-deployment.yml
    # kubectl wait --for=jsonpath='{.status.phase}=Running pod -l app.kubernetes.io/instance=ingress
    iter=1
    until kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=ingress --timeout=5s; do
        echo '[INFO] Waiting for ingress to be ready - iteration $iter'
        sleep 5
        ((iter++))
    done
    sleep 5

    kubectl apply -f server/ingress.yml
    kubectl apply -f export_to_csv/ingress.yml
    kubectl apply -f display_graph/ingress.yml
    kubectl apply -f get_min_max_avg/ingress.yml
    until kubectl wait --for=condition=Ready pod --all --timeout=5s && kubectl wait --for=jsonpath='{.status.phase}'=Running pod --all --timeout=5s; do
        echo '[INFO] Waiting for ingress to be ready - iteration $iter'
        sleep 5
        ((iter++))
    done"

    collect_metrics "$MAX_TIME_DEPLOY" "$DEPLOYMENT_FILE" "$DEPLOY_COMMANDS" 10
    kubectl get pods

    echo "Stop"
    collect_metrics "$MAX_TIME_END" "$END_FILE" "sudo systemctl stop k3s" 10

    echo "Delete"
    collect_metrics "$MAX_TIME_DELETE" "$DELETE_FILE" "sudo /usr/local/bin/k3s-uninstall.sh" 10
    echo "Completed iteration $i"
done

echo "done"

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