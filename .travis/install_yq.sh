#!/usr/bin/env bash

curl -L https://github.com/mikefarah/yq/releases/download/3.3.2/yq_linux_amd64 > yq && chmod +x yq
curl -fsSL -o yq_linux_s390x.tar.gz https://github.com/mikefarah/yq/releases/download/v4.11.1/yq_linux_s390x.tar.gz && tar xf yq_linux_s390x.tar.gz && chmod +x yq_linux_s390x && rm yq_linux_s390x.tar.gz
sudo mv yq_linux_s390x /usr/bin/
