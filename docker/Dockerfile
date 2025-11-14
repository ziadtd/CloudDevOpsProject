#Stage 1
FROM python:3.11-slim AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2
FROM python:3.11-slim

ENV PATH=/home/appuser/.local/bin:$PATH

RUN useradd -m -u 1001 -s /bin/bash appuser

USER appuser

WORKDIR /app

COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local

COPY  app.py .
COPY  templates/ ./templates/
COPY  static/ ./static/

EXPOSE 5000

CMD ["python", "app.py"]
