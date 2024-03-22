FROM mcr.microsoft.com/devcontainers/python:3.10-bullseye

RUN apt-get update && apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        jq \
        lsb-release \
        shellcheck \
        unzip \
        vim \
    && rm -rf /var/lib/apt/lists/*

# Install Azure CLI latest (2.51.0)
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install bicep
RUN az bicep install

# Helpful aliases
RUN echo 'alias ll='"'"'ls $LS_OPTIONS -al'"'"'' >> /etc/bash.bashrc

# Install Python requirements
RUN python -m pip install --upgrade pip
COPY ./requirements.txt .
COPY ./requirements_dev.txt .
RUN python -m pip install -r ./requirements_dev.txt
