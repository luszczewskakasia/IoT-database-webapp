#!/bin/bash

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
for i in $(seq 1 3); do
    docker build -t rpi:sensor_$i --build-arg SENSOR_NUMBER=sensor_$i .
    docker run -dit -p 700$i:7000 -e SENSOR_NUMBER=sensor_$i rpi:sensor_$i
done
