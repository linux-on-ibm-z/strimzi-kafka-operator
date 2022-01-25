#!/usr/bin/env bash

export PATH=$HOME/apache-maven-3.8.2/bin:$PATH

echo $(pwd)
# Build kaniko-executor docker image locally
cd $HOME
echo $HOME
docker pull gcr.io/kaniko-project/executor:76624697df879f7c3e3348f22b8c986071af4835
docker tag gcr.io/kaniko-project/executor:76624697df879f7c3e3348f22b8c986071af4835 gcr.io/kaniko-project/executor:v1.7.0
docker save --output kaniko-executor.tar gcr.io/kaniko-project/executor:v1.7.0
docker load --input kaniko-executor.tar
docker run --rm gcr.io/kaniko-project/executor:v1.7.0 version