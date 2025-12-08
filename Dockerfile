FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# 1. Dependencies
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 2. Copy source
COPY app/ .

EXPOSE 8080

# 3. Run app
CMD ["python", "app.py"]
