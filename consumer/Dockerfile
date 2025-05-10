FROM python:3.12
RUN adduser test-user
USER test-user
WORKDIR /home/test-user/consumer
COPY consumer/requirements.txt .
RUN pip install -r requirements.txt
COPY server/server.py .
COPY consumer/database.py .
CMD ["python", "consumer.py"]

