#!/usr/bin/env bash

# Build Strimzi-kafka-bridge binary and docker image
cd $HOME
export DOCKER_TAG=latest
git clone https://github.com/strimzi/strimzi-kafka-bridge.git
make java_package docker_build
