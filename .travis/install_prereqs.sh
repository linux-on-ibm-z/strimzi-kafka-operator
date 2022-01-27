#!/usr/bin/env bash

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata
sudo apt-get install -y apt-utils
sudo apt-get install -y git make cmake gcc-8 g++-8 tar wget patch ruby curl conntrack shellcheck maven openssl libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev libarchive-dev diffutils gzip file procps python3 perl zip
sudo update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-8 40
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 40
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 40
sudo update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-8 40

mvn --version