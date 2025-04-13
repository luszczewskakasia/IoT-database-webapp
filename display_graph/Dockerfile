FROM python:3.12
RUN adduser test-user
USER test-user
WORKDIR ~/display_graph
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY display_graph.py .
COPY database.py . 
CMD ["python", "-m", "flask", "--app", "display_graph", "--debug", "run", "--host", "0.0.0.0"]
