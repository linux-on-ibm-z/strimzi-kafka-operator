#!/usr/bin/env bash

export PATH=$HOME/apache-maven-3.8.2/bin:$PATH

# Install buildx for docker
mkdir -p ~/.docker/cli-plugins
curl -sSL "https://github.com/docker/buildx/releases/download/v0.6.1/buildx-v0.6.1.linux-s390x" > ~/.docker/cli-plugins/docker-buildx
chmod a+x ~/.docker/cli-plugins/docker-buildx

# Build kaniko-executor docker image locally
cd $HOME
git clone -b v1.7.0 https://github.com/GoogleContainerTools/kaniko.git
cd kaniko/
docker pull golang:1.15 # workaround due to buildx issue
docker pull debian:buster-slim # workaround due to buildx issue
docker buildx build --platform linux/s390x --load --build-arg GOARCH=s390x -t local/kaniko-project/executor:v1.7.0 -f ./deploy/Dockerfile .
docker tag local/kaniko-project/executor:v1.7.0 gcr.io/kaniko-project/executor:v1.7.0

# Build Strimzi-kafka-operator binaries and docker images
cd $HOME
git clone -b s390x_tci https://github.com/linux-on-ibm-z/strimzi-kafka-operator.git 
cd strimzi-kafka-operator/

export DOCKER_TAG=latest
export DOCKER_BUILDX=buildx
export DOCKER_BUILD_ARGS="--platform linux/s390x --load"
make clean
make MVN_ARGS='-q -DskipTests -DskipITs' java_install
make MVN_ARGS='-q -DskipTests -DskipITs' docker_build
