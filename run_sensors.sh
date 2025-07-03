#!/bin/bash

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
for i in $(seq 10 13); do
    # docker build -t rpi:sensor_$i --build-arg SENSOR_NUMBER=sensor_$i rpi/temperature
    docker run -dit -p 70$i:7000 -e SENSOR_NUMBER=sensor_$i rpi:sensor_$i
done

for i in $(seq 14 17); do
    # docker build -t rpi:sensor_$i --build-arg SENSOR_NUMBER=sensor_$i rpi/pressure
    docker run -dit -p 70$i:7000 -e SENSOR_NUMBER=sensor_$i rpi:sensor_$i
done

for i in $(seq 18 20); do
    # docker build -t rpi:sensor_$i --build-arg SENSOR_NUMBER=sensor_$i rpi/humidity
    docker run -dit -p 70$i:7000 -e SENSOR_NUMBER=sensor_$i rpi:sensor_$i
done

for i in $(seq 1 9); do
    # docker build -t rpi:sensor_$i --build-arg SENSOR_NUMBER=sensor_$i rpi/temperature
    docker run -dit -p 700$i:7000 -e SENSOR_NUMBER=sensor_$i rpi:sensor_$i
done

# for i in $(seq 14 17); do
#     docker build -t rpi:sensor_$i --build-arg SENSOR_NUMBER=sensor_$i rpi/pressure
#     docker run -dit -p 70$i:7000 -e SENSOR_NUMBER=sensor_$i rpi:sensor_$i
# done

# for i in $(seq 18 20); do
#     docker build -t rpi:sensor_$i --build-arg SENSOR_NUMBER=sensor_$i rpi/humidity
#     docker run -dit -p 70$i:7000 -e SENSOR_NUMBER=sensor_$i rpi:sensor_$i
# done

# docker build -t rpi:sensor_7 --build-arg SENSOR_NUMBER=sensor_7 rpi/temperature
# docker run -dit -p 7007:7000 -e SENSOR_NUMBER=sensor_7 rpi:sensor_7

# docker build -t rpi:sensor_8 --build-arg SENSOR_NUMBER=sensor_8 rpi/pressure
# docker run -dit -p 7008:7000 -e SENSOR_NUMBER=sensor_$i rpi:sensor_8

# docker build -t rpi:sensor_9 --build-arg SENSOR_NUMBER=sensor_9 rpi/humidity
# docker run -dit -p 7009:7000 -e SENSOR_NUMBER=sensor_9 rpi:sensor_9

# docker build -t rpi:sensor_10 --build-arg SENSOR_NUMBER=sensor_10 rpi/temperature
# docker run -dit -p 7010:7000 -e SENSOR_NUMBER=sensor_10 rpi:sensor_10