#!/usr/bin/env bash
set -e

export PATH=$HOME/apache-maven-3.8.2/bin:$PATH

export PULL_REQUEST=${PULL_REQUEST:-true}
export BRANCH=${BRANCH:-main}
export TAG=${TAG:-latest}
#export DOCKER_ORG=${DOCKER_ORG:-strimzici}
export DOCKER_ORG=${DOCKER_ORG:-strimzi}
export DOCKER_REGISTRY=quay.io
#export DOCKER_TAG=$COMMIT
export DOCKER_TAG=${TAG:-latest}

mv container-archives.tar.gz docker-images/
cd docker-images
tar xvf container-archives.tar.gz
rm -f container-archives.tar.gz
cd ..

echo "Reloading docker images from tar balls and tag them"
make docker_load docker_tag
echo "Building java artifacts"
make MVN_ARGS='-q -DskipTests -Dmaven.javadoc.skip=true' java_install
echo "Running unit tests"
mvn -e -V -B $MVN_ARGS_T -DskipITs install