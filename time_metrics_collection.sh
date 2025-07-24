#!/bin/bash

OUTPUT_FILE="time_test.csv"
NUM_ITERATIONS=1

echo "iteration,start_time,deployment_time,stop_time,delete_time" > "$OUTPUT_FILE"

measure_times() {
    local iteration=$1

    echo "[INFO] Measuring minikube start time - iteration $iteration"
    start_time=$(date +%s.%N)
    minikube start --insecure-registry="192.168.100.15:8000"
    end_time=$(date +%s.%N)
    start_duration=$(echo "$end_time - $start_time" | bc)

    echo "[INFO] Measuring deployment time - iteration $iteration"
    start_time=$(date +%s.%N)
    helm install sensor-db-postgresql bitnami/postgresql --set auth.postgresPassword=postgres --set volumePermissions.enabled=true
    helm install rabbitmq bitnami/rabbitmq --set auth.username=guest --set auth.password=guest --set auth.forcePassword=true --set rabbitmq.extraConfiguration='loopback_users = none'
    helm install ingress ingress-nginx/ingress-nginx --set controller.service.nodePorts.http=31145
    minikube kubectl -- apply -f server/server-deployment.yml
    minikube kubectl -- apply -f consumer/consumer-deployment.yml
    minikube kubectl -- apply -f producer/producer-deployment.yml
    minikube kubectl -- apply -f export_to_csv/export-csv-deployment.yml
    minikube kubectl -- apply -f display_graph/display-graph-deployment.yml
    minikube kubectl -- apply -f get_min_max_avg/get-values-deployment.yml
    # kubectl wait --for=jsonpath='{.status.phase}'=Running pod -l app.kubernetes.io/instance=ingress
    iter=1
    until minikube kubectl -- wait --for=condition=Ready pod -l app.kubernetes.io/instance=ingress --timeout=5s; do
        echo "[INFO] Waiting for ingress to be ready - iteration $iter"
        sleep 5
        ((iter++))
    done
    sleep 5

    minikube kubectl -- apply -f server/ingress.yml
    minikube kubectl -- apply -f export_to_csv/ingress.yml
    minikube kubectl -- apply -f display_graph/ingress.yml
    minikube kubectl -- apply -f get_min_max_avg/ingress.yml
    until minikube kubectl -- wait --for=condition=Ready pod --all --timeout=5s && minikube kubectl -- wait --for=jsonpath='{.status.phase}'=Running pod --all --timeout=5s; do
        echo "[INFO] Waiting for ingress to be ready - iteration $iter"
        sleep 5
        ((iter++))
    done

    end_time=$(date +%s.%N)
    minikube kubectl -- get pods
    deploy_duration=$(echo "$end_time - $start_time" | bc)

    # echo "[INFO] Measuring minikube stop time - iteration $iteration"
    # start_time=$(date +%s.%N)
    # minikube stop
    # end_time=$(date +%s.%N)
    # stop_duration=$(echo "$end_time - $start_time" | bc)

    # echo "[INFO] Measuring minikube delete time - iteration $iteration"
    # start_time=$(date +%s.%N)
    # minikube delete
    # end_time=$(date +%s.%N)
    # delete_duration=$(echo "$end_time - $start_time" | bc)

    echo "$iteration,$start_duration,$deploy_duration,$stop_duration,$delete_duration" >> "$OUTPUT_FILE"
}

# for i in $(seq 1 $NUM_ITERATIONS); do
#     echo "[INFO] Starting iteration $i of $NUM_ITERATIONS"
#     measure_times $i
#     echo "[INFO] Completed iteration $i"
# done

measure_times 1

echo "[INFO] All measurements completed. Results saved in $OUTPUT_FILE"