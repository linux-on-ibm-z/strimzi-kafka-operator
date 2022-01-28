#!/usr/bin/env bash
curl -fsSL -o yq_linux_s390x.tar.gz https://github.com/mikefarah/yq/releases/download/v4.11.1/yq_linux_s390x.tar.gz
tar xf yq_linux_s390x.tar.gz
chmod +x yq_linux_s390x
sudo mv yq_linux_s390x /usr/local/bin/yq
