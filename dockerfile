FROM python:3.10-slim

WORKDIR /app

COPY app-files .

EXPOSE 3000

CMD ["python3", "-m", "http.server", "3000"]