FROM nvidia/cuda:12.6.2-cudnn-devel-ubuntu22.04 as base

ARG DEBIAN_FRONTEND=noninteractive
RUN <<EOF
apt update -y && apt upgrade -y && apt install -y --no-install-recommends  \
    git \
    git-lfs \
    python3 \
    python3-pip \
    python3-dev \
    wget \
    vim \
    libsndfile1 \
&& rm -rf /var/lib/apt/lists/*
EOF

RUN wget https://github.com/Kitware/CMake/releases/download/v3.26.1/cmake-3.26.1-Linux-x86_64.sh \
    -q -O /tmp/cmake-install.sh \
    && chmod u+x /tmp/cmake-install.sh \
    && mkdir /opt/cmake-3.26.1 \
    && /tmp/cmake-install.sh --skip-license --prefix=/opt/cmake-3.26.1 \
    && rm /tmp/cmake-install.sh \
    && ln -s /opt/cmake-3.26.1/bin/* /usr/local/bin

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN git lfs install

FROM base as dev

WORKDIR /

RUN mkdir -p /data/shared/Qwen

WORKDIR /data/shared/Qwen/

FROM dev as bundle_req
RUN pip3 install --no-cache-dir networkx==3.1
RUN pip3 install --no-cache-dir torch==2.4.0 torchvision==0.19 torchaudio==2.4.0 xformers==0.0.27.post2 --index-url https://download.pytorch.org/whl/cu121

RUN pip3 install --no-cache-dir git+https://github.com/huggingface/transformers@21fac7abba2a37fae86106f87fcf9974fd1e3830  \
    && pip3 install --no-cache-dir accelerate \
    && pip3 install --no-cache-dir qwen-vl-utils

FROM bundle_req as bundle_vllm

RUN pip3 install --no-cache-dir --no-build-isolation flash-attn==2.6.1

RUN mkdir -p /data/shared/code \
    && cd /data/shared/code \
    && git clone https://github.com/fyabc/vllm.git \
    && cd vllm \
    && git checkout add_qwen2_vl_new \
    && pip3 install --no-cache-dir -r requirements-cuda.txt \
    && pip3 install --no-cache-dir --no-build-isolation . \
    && cd /data/shared/Qwen \
    && rm -rf /data/shared/code/vllm

RUN pip3 install --no-cache-dir \
    gradio==4.42.0 \
    gradio_client==1.3.0 \
    transformers-stream-generator==0.0.4

WORKDIR /app/qwen2-vl
COPY ./main.py ./
RUN pip3 install --no-cache-dir fastapi uvicorn
EXPOSE 8000
CMD [ "uvicorn", "main:app", "--host", "0.0.0.0" ]