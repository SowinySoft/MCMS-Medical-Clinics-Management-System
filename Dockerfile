# Backend image: Django 5 + DRF + Channels/Daphne, served over HTTP+WS.
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# System deps (postgres client for setup_db.sh + wait-for-it style checks)
RUN apt-get update && apt-get install -y --no-install-recommends \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Python deps first (layer cache)
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# App source
COPY . .

# Static files (admin / drf-spectacular) collected for nginx to serve
RUN python -m manage.py collectstatic --noinput || true

EXPOSE 8010

# Entrypoint: wait for postgres, build/verify DB, then run Daphne (HTTP+WS)
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
