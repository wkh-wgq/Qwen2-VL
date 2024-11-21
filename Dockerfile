# syntax=docker/dockerfile:1
FROM wangkaihua/qwen2-vl-base:v1
WORKDIR /app/qwen2-vl
COPY . .
RUN pip install -r requirements_main.txt && pip install flash-attn --no-build-isolation
EXPOSE 8000
CMD [ "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000" ]