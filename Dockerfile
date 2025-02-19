FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN mkdir -p thumbs

# Create default thumbnail
RUN convert -size 320x240 xc:black default_thumb.jpg

CMD ["python", "main.py"]
