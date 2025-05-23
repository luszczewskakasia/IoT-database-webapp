FROM python:3.12
RUN adduser test-user
USER test-user
WORKDIR /home/test-user/consumer
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY consumer.py .
COPY database.py .
CMD ["python", "consumer.py"]

