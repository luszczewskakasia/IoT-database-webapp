#!/bin/bash

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
for i in $(seq 1 2); do
    docker build -t rpi:sensor_$i --build-arg SENSOR_NUMBER=sensor_$i rpi/temperature
    docker run -dit -p 700$i:7000 -e SENSOR_NUMBER=sensor_$i rpi:sensor_$i
done

for i in $(seq 3 4); do
    docker build -t rpi:sensor_$i --build-arg SENSOR_NUMBER=sensor_$i rpi/pressure
    docker run -dit -p 700$i:7000 -e SENSOR_NUMBER=sensor_$i rpi:sensor_$i
done

for i in $(seq 5 6); do
    docker build -t rpi:sensor_$i --build-arg SENSOR_NUMBER=sensor_$i rpi/humidity
    docker run -dit -p 700$i:7000 -e SENSOR_NUMBER=sensor_$i rpi:sensor_$i
done