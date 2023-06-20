FROM ubuntu:21.10

RUN apt-get update -y && \
    apt-get install -y bash

WORKDIR /app