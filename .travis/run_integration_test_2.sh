#!/usr/bin/env bash
set -e

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

export PULL_REQUEST=${PULL_REQUEST:-true}
export BRANCH=${BRANCH:-main}
export TAG=${TAG:-latest}
#export DOCKER_ORG=${DOCKER_ORG:-strimzici}
export DOCKER_ORG=${DOCKER_ORG:-strimzi}
export DOCKER_REGISTRY=${DOCKER_REGISTRY:-quay.io}
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
mvn -e -V -B -Dmaven.javadoc.skip=true -DskipITs -Dsurefire.rerunFailingTestsCount=5 -Dfailsafe.rerunFailingTestsCount=2 install