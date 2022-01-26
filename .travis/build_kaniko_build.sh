#!/usr/bin/env bash

export PATH=$HOME/apache-maven-3.8.2/bin:$PATH

echo $(pwd)
CUR_PATH=$(pwd)
# Build kaniko-executor docker image locally
cd ${HOME}/build
echo "${HOME}/build"
docker pull gcr.io/kaniko-project/executor:76624697df879f7c3e3348f22b8c986071af4835
docker tag gcr.io/kaniko-project/executor:76624697df879f7c3e3348f22b8c986071af4835 gcr.io/kaniko-project/executor:v1.7.0
docker save gcr.io/kaniko-project/executor:v1.7.0 | gzip > ${CUR_PATH}/kaniko-executor.tar.gz