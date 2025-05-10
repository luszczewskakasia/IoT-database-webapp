FROM python:3.12
RUN adduser test-user
USER test-user
WORKDIR /home/test-user/producer
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY producer.py .
CMD ["python", "producer.py"]