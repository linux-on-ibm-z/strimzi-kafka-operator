#!/usr/bin/env bash
set -e

# The first segment of the version number is '1' for releases < 9; then '9', '10', '11', ...
JAVA_MAJOR_VERSION=$(java -version 2>&1 | sed -E -n 's/.* version "([0-9]*).*$/\1/p')
if [ ${JAVA_MAJOR_VERSION} -eq 11 ] ; then
  # some parts of the workflow should be done only one on the main build which is currently Java 11
  export MAIN_BUILD="TRUE"
fi

export PULL_REQUEST=${PULL_REQUEST:-true}
export BRANCH=${BRANCH:-main}
export TAG=${TAG:-latest}
#export DOCKER_ORG=${DOCKER_ORG:-strimzici}
export DOCKER_ORG=${DOCKER_ORG:-strimzi}
export DOCKER_REGISTRY=${DOCKER_REGISTRY:-quay.io}
#export DOCKER_TAG=$COMMIT
export DOCKER_TAG=${TAG:-latest}

echo "Reloading docker images from tar balls and tag them"
make docker_load docker_tag
echo "Running unit tests and integration tests"
mvn -e -V -B -Dmaven.javadoc.skip=true -Dsurefire.rerunFailingTestsCount=5 -Dfailsafe.rerunFailingTestsCount=2 install
#make shellcheck
#make docu_check
#make spotbugs

#make crd_install
#make helm_install
