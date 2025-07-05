# Copyright 2025 The MathWorks, Inc.
ARG BASE_IMAGE=padv:latest

FROM ${BASE_IMAGE}

RUN export DEBIAN_FRONTEND=noninteractive \
    && sudo apt-get update \
    && sudo apt-get install --no-install-recommends --yes \
    python3 3.12 \
    python3-pip \
    git \
    curl \
    && sudo apt-get clean \
    && sudo apt-get autoremove \
    && sudo rm -rf /var/lib/apt/lists/*

RUN pip install colorlog

# Installing jfrog cli, azure cli and aws cli
RUN curl -fL https://getcli.jfrog.io/setup | sh
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo /bin/bash
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
        sudo unzip awscliv2.zip && \
        sudo ./aws/install && \
        sudo rm -rf awscliv2.zip aws

ENV HOME=/home/matlab
ENTRYPOINT [""]