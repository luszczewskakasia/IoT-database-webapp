#!/bin/bash

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
for i in $(seq 1 9); do
    # docker build -t rpi:sensor_$i --build-arg SENSOR_NUMBER=sensor_$i rpi/temperature
    docker run -dit -p 700$i:7000 -e SENSOR_NUMBER=sensor_$i rpi:sensor_$i
done

for i in $(seq 10 20); do
    # docker build -t rpi:sensor_$i --build-arg SENSOR_NUMBER=sensor_$i rpi/temperature
    docker run -dit -p 70$i:7000 -e SENSOR_NUMBER=sensor_$i rpi:sensor_$i
done


docker run -dit -p 7010:7000 -e SENSOR_NUMBER=sensor_10 rpi:sensor_10