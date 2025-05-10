FROM python:3.12
RUN adduser test-user
USER test-user
WORKDIR ~/export_to_csv
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY export_to_csv.py .
COPY database.py .
CMD ["python", "-m", "flask", "--app", "export_to_csv", "--debug", "run", "--host", "0.0.0.0"]