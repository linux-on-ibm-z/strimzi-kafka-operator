PROJECT_NAME=kafka-agent-3

docker_build: java_install
docker_push:
docker_tag:
all: docker_build docker_push
clean: java_clean

include ../Makefile.maven

.PHONY: build clean release
