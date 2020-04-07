#!/usr/bin/env bash

curl -L https://github.com/mikefarah/yq/releases/download/3.2.1/yq_linux_$(uname -m) > yq && chmod +x yq
sudo cp yq /usr/bin/
