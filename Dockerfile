--- public/code/Dockerfile (原始)


+++ public/code/Dockerfile (修改后)
     1	FROM python:3.11-slim
     2	
     3	WORKDIR /app
     4	
     5	# Install system dependencies
     6	RUN apt-get update && \
     7	    apt-get install -y --no-install-recommends curl && \
     8	    rm -rf /var/lib/apt/lists/*
     9	
    10	# Copy requirements first for layer caching
    11	COPY requirements.txt .
    12	RUN pip install --no-cache-dir -r requirements.txt
    13	
    14	# Copy application code
    15	COPY . .
    16	
    17	# Create non-root user
    18	RUN useradd --create-home --shell /bin/bash botuser && \
    19	    mkdir -p /app/logs && \
    20	    chown -R botuser:botuser /app
    21	USER botuser
    22	
    23	# Health check
    24	HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
    25	    CMD curl -f http://localhost:8080/health || exit 1
    26	
    27	# Run the bot
    28	CMD ["python", "main.py"]
    29	
