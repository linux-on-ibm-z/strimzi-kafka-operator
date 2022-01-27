#!/usr/bin/env bash

export CUR_DIR=$(pwd)

export PATH=$HOME/apache-maven-3.8.2/bin:$PATH
echo $PATH

# Build kaniko-executor docker image locally
cd $HOME
git clone -b v1.7.0 https://github.com/GoogleContainerTools/kaniko.git
cd kaniko/
docker pull golang:1.15 # workaround due to buildx issue
docker pull debian:buster-slim # workaround due to buildx issue
docker buildx build --platform linux/s390x --load --build-arg GOARCH=s390x -t local/kaniko-project/executor:v1.7.0 -f ./deploy/Dockerfile .
docker tag local/kaniko-project/executor:v1.7.0 gcr.io/kaniko-project/executor:v1.7.0

# Build Strimzi-kafka-operator binaries and docker images
cd $CUR_DIR
export DOCKER_TAG=latest
export DOCKER_BUILDX=buildx
export DOCKER_BUILD_ARGS="--platform linux/s390x --load"
make clean
echo "Building java artifacts"
make MVN_ARGS='-q -DskipTests -Dmaven.javadoc.skip=true' java_install
echo "Building docker images"
make MVN_ARGS='-q -DskipTests -Dmaven.javadoc.skip=true' docker_build
echo "Listing rocksdbjni files"
find . $HOME/.m2 -name "*rocksdb*.jar"
echo "Listing s390x rocksdbjni files"
find . $HOME/.m2 -name "*rocksdb*.jar" -print0 | xargs -0 -n1 unzip -l | grep s390x
echo "Saving docker images as tar balls"
make docker_save
cd docker-images
tar -czf container-archives.tar.gz container-archives/
mv container-archives.tar.gz ../

