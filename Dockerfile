# syntax=docker/dockerfile:1
FROM qwenllm/qwenvl:2-cu121
WORKDIR /app/qwen2-vl
COPY ./main.py ./
RUN pip3 install -r requirements_main.txt
EXPOSE 8000
CMD [ "uvicorn", "main:app", "--host", "0.0.0.0" ]