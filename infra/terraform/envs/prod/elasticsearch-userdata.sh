#!/bin/bash
set -euo pipefail

apt-get update
apt-get install -y docker.io
systemctl enable docker
systemctl start docker

docker run -d --name elasticsearch \
  -p 9200:9200 \
  -p 9300:9300 \
  -e discovery.type=single-node \
  -e xpack.security.enabled=false \
  -e ES_JAVA_OPTS='-Xms512m -Xmx512m' \
  elasticsearch:8.15.3
