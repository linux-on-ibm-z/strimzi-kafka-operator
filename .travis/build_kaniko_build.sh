#!/usr/bin/env bash

export PATH=$HOME/apache-maven-3.8.2/bin:$PATH

# Build kaniko-executor docker image locally
cd $HOME
echo $HOME
docker pull gcr.io/kaniko-project/executor:76624697df879f7c3e3348f22b8c986071af4835
docker tag gcr.io/kaniko-project/executor:76624697df879f7c3e3348f22b8c986071af4835 gcr.io/kaniko-project/executor:v1.8.0
docker save gcr.io/kaniko-project/executor:v1.8.0 | gzip > kaniko-executor.tar.gz
docker load < kaniko-executor.tar.gz
docker run --rm gcr.io/kaniko-project/executor:v1.8.0 version