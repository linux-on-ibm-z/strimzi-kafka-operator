#!/usr/bin/env bash

# Install buildx for docker
mkdir -p ~/.docker/cli-plugins
curl -sSL "https://github.com/docker/buildx/releases/download/v0.6.1/buildx-v0.6.1.linux-s390x" > ~/.docker/cli-plugins/docker-buildx
chmod a+x ~/.docker/cli-plugins/docker-buildx

# Build Strimzi-kafka-operator binaries and docker images
export DOCKER_TAG=latest
export DOCKER_BUILDX=buildx
export DOCKER_BUILD_ARGS="--platform linux/s390x --load"
make clean
make MVN_ARGS='-q -DskipTests -DskipITs' java_install
make MVN_ARGS='-q -DskipTests -DskipITs' docker_build
