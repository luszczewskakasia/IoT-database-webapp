FROM python:3.12
RUN adduser test-user
USER test-user
WORKDIR /home/test-user/rpi
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY rpi_code.py .
CMD ["python", "-m", "flask", "--app", "rpi_code", "--debug", "run", "--host", "0.0.0.0"]
