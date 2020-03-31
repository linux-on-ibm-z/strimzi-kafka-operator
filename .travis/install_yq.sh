#!/usr/bin/env bash

if [[ $(uname -m) == 's390x' ]]; then
  curl -L https://github.com/mikefarah/yq/releases/download/3.2.1/yq_linux_s390x > yq && chmod +x yq
else
  curl -L https://github.com/mikefarah/yq/releases/download/3.2.1/yq_linux_amd64 > yq && chmod +x yq
fi
sudo cp yq /usr/bin/
