#!/usr/bin/env bash

find . -name '*kaniko-executor.tar.gz*'

docker load < kaniko-executor.tar.gz

docker run --rm gcr.io/kaniko-project/executor:v1.7.0 version