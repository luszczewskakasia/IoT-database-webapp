#!/bin/bash

OUTPUT_FILE="test_time.csv"
NUM_ITERATIONS=10

echo "iteration,start_time,deployment_time,stop_time,delete_time" > "$OUTPUT_FILE"

measure_times() {
    local iteration=$1

    echo "start time - iteration $iteration"
    start_time=$(date +%s.%N)
    sudo snap install microk8s --classic --channel=1.32
    end_time=$(date +%s.%N)
    start_duration=$(echo "$end_time - $start_time" | bc)

    sudo mkdir -p /var/snap/microk8s/current/args/certs.d/192.168.100.15:8000
    sudo touch /var/snap/microk8s/current/args/certs.d/192.168.100.15:8000/hosts.toml
    cat mirror.sh | sudo tee /var/snap/microk8s/current/args/certs.d/192.168.100.15:8000/hosts.toml
    microk8s stop
    microk8s start
    microk8s enable hostpath-storage
    echo "[INFO] Measuring deployment time - iteration $iteration"
    start_time=$(date +%s.%N)
    microk8s helm3 install sensor-db-postgresql bitnami/postgresql --set auth.postgresPassword=postgres --set volumePermissions.enabled=true --version 16.7.14
    microk8s helm3 install rabbitmq bitnami/rabbitmq --set auth.username=guest --set auth.password=guest --set auth.forcePassword=true --set rabbitmq.extraConfiguration='loopback_users = none'
    microk8s helm3 install ingress ingress-nginx/ingress-nginx --set controller.service.nodePorts.http=31145
    microk8s kubectl apply -f server/server-deployment.yml
    microk8s kubectl apply -f consumer/consumer-deployment.yml
    microk8s kubectl apply -f producer/producer-deployment.yml
    microk8s kubectl apply -f export_to_csv/export-csv-deployment.yml
    microk8s kubectl apply -f display_graph/display-graph-deployment.yml
    microk8s kubectl apply -f get_min_max_avg/get-values-deployment.yml
    # kubectl wait --for=jsonpath='{.status.phase}'=Running pod -l app.kubernetes.io/instance=ingress
    iter=1
    until microk8s kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=ingress --timeout=5s; do
        echo "[INFO] Waiting for ingress to be ready - iteration $iter"
        sleep 5
        ((iter++))
    done
    sleep 5

    microk8s kubectl apply -f server/ingress.yml
    microk8s kubectl apply -f export_to_csv/ingress.yml
    microk8s kubectl apply -f display_graph/ingress.yml
    microk8s kubectl apply -f get_min_max_avg/ingress.yml
    until microk8s kubectl wait --for=condition=Ready pod --all --timeout=5s && microk8s kubectl wait --for=jsonpath='{.status.phase}'=Running pod --all --timeout=5s; do
        echo "[INFO] Waiting for ingress to be ready - iteration $iter"
        sleep 5
        ((iter++))
    done

    end_time=$(date +%s.%N)
    microk8s kubectl get pods
    deploy_duration=$(echo "$end_time - $start_time" | bc)

    echo "[INFO] Measuring stop time - iteration $iteration"
    start_time=$(date +%s.%N)
    microk8s stop
    end_time=$(date +%s.%N)
    stop_duration=$(echo "$end_time - $start_time" | bc)

    echo "[INFO] Measuring delete time - iteration $iteration"
    start_time=$(date +%s.%N)
    sudo snap remove microk8s
    end_time=$(date +%s.%N)
    delete_duration=$(echo "$end_time - $start_time" | bc)

    echo "$iteration,$start_duration,$deploy_duration,$stop_duration,$delete_duration" >> "$OUTPUT_FILE"
}

for i in $(seq 1 $NUM_ITERATIONS); do
    echo "[INFO] Starting iteration $i of $NUM_ITERATIONS"
    measure_times $i
    echo "[INFO] Completed iteration $i"
done


echo "[INFO] All measurements completed. Results saved in $OUTPUT_FILE"