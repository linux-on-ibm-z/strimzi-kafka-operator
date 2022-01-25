#!/usr/bin/env bash

export PATH=$HOME/apache-maven-3.8.2/bin:$PATH

# Build kaniko-executor docker image locally
cd $HOME
git clone -b v1.7.0 https://github.com/GoogleContainerTools/kaniko.git
cd kaniko/
docker pull golang:1.15 # workaround due to buildx issue
docker pull debian:buster-slim # workaround due to buildx issue
docker buildx build --platform linux/s390x --load --build-arg GOARCH=s390x -t local/kaniko-project/executor:v1.7.0 -f ./deploy/Dockerfile .
docker tag local/kaniko-project/executor:v1.7.0 gcr.io/kaniko-project/executor:v1.7.0
docker save gcr.io/kaniko-project/executor:v1.7.0 | gzip > kaniko-executor.tar.gz