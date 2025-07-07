#!/bin/bash

OUTPUT_FILE="time.csv"
NUM_ITERATIONS=1

echo "iteration,start_time,deployment_time,stop_time,delete_time" > "$OUTPUT_FILE"

measure_times() {
    local iteration=$1
    ### EXEC WAS CHANGED -> https://medium.com/@alesson.viana/installing-the-nginx-ingress-controller-on-k3s-df2c68cae3c8
    # EARLIER WAS INSTALL_K3S_EXEC="--disable servicelb, traefik"
    curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="server - no-deploy traefik" sh -s - --node-name k3s-master
    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
    sudo chown $USER:$USER ~/.kube/config  
    cat mirror.sh | sudo tee /etc/rancher/k3s/registries.yaml
    sudo systemctl restart k3s
    echo "start time - iteration $iteration"
    start_time=$(date +%s.%N)
    sudo systemctl start k3s
    end_time=$(date +%s.%N)
    start_duration=$(echo "$end_time - $start_time" | bc)

    echo "[INFO] Measuring deployment time - iteration $iteration"
    start_time=$(date +%s.%N)
    helm install sensor-db-postgresql bitnami/postgresql --set auth.postgresPassword=postgres --set volumePermissions.enabled=true --version 16.7.14
    helm install rabbitmq bitnami/rabbitmq --set auth.username=guest --set auth.password=guest --set auth.forcePassword=true --set rabbitmq.extraConfiguration='loopback_users = none'
    helm install ingress ingress-nginx/ingress-nginx --set controller.service.nodePorts.http=31145
    kubectl apply -f server/server-deployment.yml
    kubectl apply -f consumer/consumer-deployment.yml
    kubectl apply -f producer/producer-deployment.yml
    kubectl apply -f export_to_csv/export-csv-deployment.yml
    kubectl apply -f display_graph/display-graph-deployment.yml
    kubectl apply -f get_min_max_avg/get-values-deployment.yml
    # kubectl wait --for=jsonpath='{.status.phase}'=Running pod -l app.kubernetes.io/instance=ingress
    iter=1
    until kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=ingress --timeout=5s; do
        echo "[INFO] Waiting for ingress to be ready - iteration $iter"
        sleep 5
        ((iter++))
    done
    sleep 5

    kubectl apply -f server/ingress.yml
    kubectl apply -f export_to_csv/ingress.yml
    kubectl apply -f display_graph/ingress.yml
    kubectl apply -f get_min_max_avg/ingress.yml
    until kubectl wait --for=condition=Ready pod --all --timeout=5s && kubectl wait --for=jsonpath='{.status.phase}'=Running pod --all --timeout=5s; do
        echo "[INFO] Waiting for ingress to be ready - iteration $iter"
        sleep 5
        ((iter++))
    done

    end_time=$(date +%s.%N)
    kubectl get pods
    deploy_duration=$(echo "$end_time - $start_time" | bc)

    # echo "[INFO] Measuring stop time - iteration $iteration"
    # start_time=$(date +%s.%N)
    # sudo systemctl stop k3s
    # end_time=$(date +%s.%N)
    # stop_duration=$(echo "$end_time - $start_time" | bc)

    # echo "[INFO] Measuring delete time - iteration $iteration"
    # start_time=$(date +%s.%N)
    # sudo /usr/local/bin/k3s-uninstall.sh
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