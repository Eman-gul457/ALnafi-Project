#!/usr/bin/env bash
set -euo pipefail

: "${MYSQL_HOST:?required}"
: "${MYSQL_PORT:=3306}"
: "${MYSQL_DB:=openedx}"
: "${MYSQL_USER:?required}"
: "${MYSQL_PASSWORD:?required}"
: "${MONGO_HOST:?required}"
: "${MONGO_PORT:=27017}"
: "${MONGO_USER:?required}"
: "${MONGO_PASSWORD:?required}"
: "${ELASTICSEARCH_HOST:?required}"
: "${ELASTICSEARCH_PORT:=443}"
: "${REDIS_HOST:?required}"
: "${REDIS_PORT:=6379}"

# These settings ensure all stateful services are external to Kubernetes.
tutor config save --set OPENEDX_MYSQL_HOST=${MYSQL_HOST} \
  --set OPENEDX_MYSQL_PORT=${MYSQL_PORT} \
  --set OPENEDX_MYSQL_DATABASE=${MYSQL_DB} \
  --set OPENEDX_MYSQL_USERNAME=${MYSQL_USER} \
  --set OPENEDX_MYSQL_PASSWORD=${MYSQL_PASSWORD} \
  --set OPENEDX_MONGODB_HOST=${MONGO_HOST} \
  --set OPENEDX_MONGODB_PORT=${MONGO_PORT} \
  --set OPENEDX_MONGODB_USERNAME=${MONGO_USER} \
  --set OPENEDX_MONGODB_PASSWORD=${MONGO_PASSWORD} \
  --set OPENEDX_REDIS_HOST=${REDIS_HOST} \
  --set OPENEDX_REDIS_PORT=${REDIS_PORT} \
  --set OPENEDX_ELASTICSEARCH_HOST=${ELASTICSEARCH_HOST} \
  --set OPENEDX_ELASTICSEARCH_PORT=${ELASTICSEARCH_PORT} \
  --set RUN_MYSQL=false \
  --set RUN_MONGODB=false \
  --set RUN_REDIS=false \
  --set RUN_ELASTICSEARCH=false

echo "External service configuration applied to Tutor"
