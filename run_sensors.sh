#!/bin/bash

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
for i in $(seq 1 3); do
    docker build -t rpi:sensor_$i --build-arg SENSOR_NUMBER=sensor_$i rpi/temperature
    docker run -dit -p 700$i:7000 -e SENSOR_NUMBER=sensor_$i rpi:sensor_$i
    # docker stop rpi:sensor_$i
done

for i in $(seq 4 6); do
    docker build -t rpi:sensor_$i --build-arg SENSOR_NUMBER=sensor_$i rpi/humidity
    docker run -dit -p 700$i:7000 -e SENSOR_NUMBER=sensor_$i rpi:sensor_$i
    # docker stop rpi:sensor_$i
done

for i in $(seq 7 9); do
    docker build -t rpi:sensor_$i --build-arg SENSOR_NUMBER=sensor_$i rpi/pressure
    docker run -dit -p 700$i:7000 -e SENSOR_NUMBER=sensor_$i rpi:sensor_$i
    # docker stop rpi:sensor_$i
done
# for i in $(seq 11 20); do
#     # docker build -t rpi:sensor_$i --build-arg SENSOR_NUMBER=sensor_$i rpi/temperature
#     docker run -dit -p 70$i:7000 -e SENSOR_NUMBER=sensor_$i rpi:sensor_$i
# done

# for i in $(seq 11 13); do
#     docker build -t rpi:sensor_$i --build-arg SENSOR_NUMBER=sensor_$i rpi/temperature
#     docker run -dit -p 700$i:7000 -e SENSOR_NUMBER=sensor_$i rpi:sensor_$i
#     # docker stop rpi:sensor_$i
# done

# for i in $(seq 14 16); do
#     docker build -t rpi:sensor_$i --build-arg SENSOR_NUMBER=sensor_$i rpi/humidity
#     docker run -dit -p 700$i:7000 -e SENSOR_NUMBER=sensor_$i rpi:sensor_$i
#     # docker stop rpi:sensor_$i
# done

# for i in $(seq 17 20); do
#     docker build -t rpi:sensor_$i --build-arg SENSOR_NUMBER=sensor_$i rpi/pressure
#     docker run -dit -p 700$i:7000 -e SENSOR_NUMBER=sensor_$i rpi:sensor_$i
#     # docker stop rpi:sensor_$i
# done

# docker build -t rpi:sensor_10 --build-arg SENSOR_NUMBER=sensor_10 rpi/temperature
# docker run -dit -p 7010:7000 -e SENSOR_NUMBER=sensor_10 rpi:sensor_10