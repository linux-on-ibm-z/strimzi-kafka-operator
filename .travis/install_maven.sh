#!/usr/bin/env bash

cd $HOME
wget https://archive.apache.org/dist/maven/maven-3/3.8.2/binaries/apache-maven-3.8.2-bin.tar.gz
tar -zxf apache-maven-3.8.2-bin.tar.gz
export PATH=$HOME/apache-maven-3.8.2/bin:$PATH
mvn --version