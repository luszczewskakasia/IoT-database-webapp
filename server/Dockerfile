FROM python:3.12
RUN adduser test-user
USER test-user
WORKDIR ~/server
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY server.py .
COPY database.py .
COPY templates/ ./templates/
COPY static/ ./static/
CMD ["python", "-m", "flask", "--app", "server", "--debug", "run", "--host", "0.0.0.0"]