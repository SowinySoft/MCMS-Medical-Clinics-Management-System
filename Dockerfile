# syntax=docker/dockerfile:1
# Phase 12: multi-stage image for MCMS (Daphne ASGI server).
FROM python:3.11-slim AS builder
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends build-essential \
    libpq-dev gcc && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir -r requirements.txt

FROM python:3.11-slim AS runtime
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 \
    MCMS_REDIS_URL=redis://redis:6379/0 \
    MCMS_CONN_MAX_AGE=60 DJANGO_SETTINGS_MODULE=config.settings
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends libpq5 \
    curl && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY . .
# Readiness/liveness are served by the API itself (/api/system/health|readiness).
# Port is taken from $PORT (miget sets immutable PORT=5000; default 8000 locally).
EXPOSE 5000
# Daphne ASGI — handles HTTP + WebSocket (Channels) on one port.
CMD ["sh", "-c", "daphne -b 0.0.0.0 -p ${PORT:-8000} config.asgi:application"]
