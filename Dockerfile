# Production Dockerfile for Nepali Devanagari OCR Pipeline
FROM python:3.11-slim

# Prevent Python from writing .pyc files and buffer stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy dependencies first for Docker cache optimization
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source code
COPY ocr_pipeline.py .

# Create non-root user and data/output directories with appropriate permissions
RUN useradd -u 1000 -m appuser && \
    mkdir -p /app/data /app/output && \
    chown -R appuser:appuser /app

USER appuser

# Expose volume mount points for PDF input and DOCX output
VOLUME ["/app/data", "/app/output"]

# Default entrypoint to run the OCR pipeline
ENTRYPOINT ["python", "ocr_pipeline.py"]
CMD ["--input", "data", "--output", "output"]
