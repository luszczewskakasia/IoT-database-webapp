
# FROM balenalib/raspberry-pi-debian-python:latest
# FROM ghcr.io/carlosperate/qemu-rpi-vm:2024-01-03
# FROM ghcr.io/carlosperate/qemu-rpi-os-lite:bullseye-2023-05-03
FROM --platform=linux/arm64 ghcr.io/dtcooper/raspberrypi-os:python3.12-bookworm
ARG SENSOR_NUMBER
COPY requirements.txt .
RUN apt update && apt install -y \
    bash \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip install -r requirements.txt
COPY rpi_code.py .
CMD ["python", "-m", "flask", "--app", "rpi_code", "--debug", "run", "--host", "0.0.0.0", "--port", "7000"]