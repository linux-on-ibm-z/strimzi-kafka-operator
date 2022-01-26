#!/usr/bin/env bash

export CUR_DIR=$(pwd)

if [ ! -f $HOME/.m2/repository/org/rocksdb/rocksdbjni/6.19.3/rocksdbjni-6.19.3.jar ]; then
    # Put locally built jni jars in the local maven repository
    mkdir -p $HOME/.m2/repository/org/rocksdb/rocksdbjni/6.19.3
    mv -f rocksdbjni-6.19.3.jar $HOME/.m2/repository/org/rocksdb/rocksdbjni/6.19.3/rocksdbjni-6.19.3.jar
    mv -f rocksdbjni-6.19.3.jar.sha1 $HOME/.m2/repository/org/rocksdb/rocksdbjni/6.19.3/rocksdbjni-6.19.3.jar.sha1
fi

if [ ! -f $HOME/.m2/repository/org/rocksdb/rocksdbjni/6.22.1.1/rocksdbjni-6.22.1.1.jar ]; then
    # Put locally built jni jars in the local maven repository
    mkdir -p $HOME/.m2/repository/org/rocksdb/rocksdbjni/6.22.1.1
    mv -f rocksdbjni-6.22.1.1.jar $HOME/.m2/repository/org/rocksdb/rocksdbjni/6.22.1.1/rocksdbjni-6.22.1.1.jar
    mv -f rocksdbjni-6.22.1.1.jar.sha1 $HOME/.m2/repository/org/rocksdb/rocksdbjni/6.22.1.1/rocksdbjni-6.22.1.1.jar.sha1
fi

export PATH=$HOME/apache-maven-3.8.2/bin:$PATH

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
echo "Saving docker images as tar balls"
make docker_save
cd docker-images
tar -czf container-archives.tar.gz container-archives/
mv container-archives.tar.gz ../

