#!/usr/bin/env bash
set -e

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
echo "Running unit tests and integration tests"
mvn -e -V -B -Dmaven.javadoc.skip=true -Dsurefire.rerunFailingTestsCount=5 -Dfailsafe.rerunFailingTestsCount=2 install
#make shellcheck
#make docu_check
#make spotbugs

#make crd_install
#make helm_install
