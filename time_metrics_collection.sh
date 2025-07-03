#!/bin/bash

OUTPUT_FILE="time.csv"
NUM_ITERATIONS=10

# Initialize CSV file with headers
echo "iteration,start_time,deployment_time,stop_time,delete_time" > "$OUTPUT_FILE"

measure_times() {
    local iteration=$1

    # Measure minikube start time
    echo "[INFO] Measuring minikube start time - iteration $iteration"
    start_time=$(date +%s.%N)
    curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="server" sh -s - --node-name k3s-master
    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
    sudo chown $USER:$USER ~/.kube/config
    end_time=$(date +%s.%N)
    start_duration=$(echo "$end_time - $start_time" | bc)

    # Measure deployment time
    echo "[INFO] Measuring deployment time - iteration $iteration"
    start_time=$(date +%s.%N)
    kubectl apply -f server/server-deployment.yml
    kubectl apply -f consumer/consumer-deployment.yml
    kubectl apply -f producer/producer-deployment.yml
    kubectl apply -f export_to_csv/export-csv-deployment.yml
    kubectl apply -f display_graph/display-graph-deployment.yml
    kubectl apply -f get_min_max_avg/get-values-deployment.yml
    helm install sensor-db-postgresql bitnami/postgresql --set auth.postgresPassword=postgres --set volumePermissions.enabled=true
    helm install rabbitmq bitnami/rabbitmq --set auth.username=guest --set auth.password=guest --set auth.forcePassword=true --set rabbitmq.extraConfiguration='loopback_users = none'
    end_time=$(date +%s.%N)
    deploy_duration=$(echo "$end_time - $start_time" | bc)

    # Measure minikube stop time
    echo "[INFO] Measuring minikube stop time - iteration $iteration"
    start_time=$(date +%s.%N)
    sudo systemctl stop k3s
    end_time=$(date +%s.%N)
    stop_duration=$(echo "$end_time - $start_time" | bc)

    # Measure minikube delete time
    echo "[INFO] Measuring minikube delete time - iteration $iteration"
    start_time=$(date +%s.%N)
    sudo /usr/local/bin/k3s-uninstall.sh
    end_time=$(date +%s.%N)
    delete_duration=$(echo "$end_time - $start_time" | bc)

    # Save results to CSV
    echo "$iteration,$start_duration,$deploy_duration,$stop_duration,$delete_duration" >> "$OUTPUT_FILE"
}

# Main loop
for i in $(seq 1 $NUM_ITERATIONS); do
    echo "[INFO] Starting iteration $i of $NUM_ITERATIONS"
    measure_times $i
    echo "[INFO] Completed iteration $i"
    echo "-------------------"
done

echo "[INFO] All measurements completed. Results saved in $OUTPUT_FILE"