FROM python:3.12
RUN adduser test-user
USER test-user
WORKDIR ~/get_min_max_avg
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY get_min_max_avg.py .
COPY database.py . 
CMD ["python", "-m", "flask", "--app", "get_min_max_avg", "--debug", "run", "--host", "0.0.0.0"]