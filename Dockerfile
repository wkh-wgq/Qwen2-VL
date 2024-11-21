# syntax=docker/dockerfile:1
FROM python:3.11-slim
WORKDIR /app/qwen2-vl
COPY . .
RUN apt-get update && apt-get install -y git
RUN pip install -r requirements_main.txt && pip install flash-attn --no-build-isolation
EXPOSE 8000
CMD [ "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000" ]