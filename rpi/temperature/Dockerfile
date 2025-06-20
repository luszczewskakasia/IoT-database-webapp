FROM --platform=linux/arm64 ghcr.io/dtcooper/raspberrypi-os:python3.12-bookworm
ARG SENSOR_NUMBER
COPY requirements.txt .
RUN apt update && apt install -y --no-install-recommends \
    python3-minimal \
    python3-dev \
    python3 \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip install -r requirements.txt
COPY rpi_code.py .
CMD ["python", "-m", "flask", "--app", "rpi_code", "--debug", "run", "--host", "0.0.0.0", "--port", "7000"]