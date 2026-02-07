#!/usr/bin/env bash
# Expected runtime: Linux host/EC2 with network access to external databases.
set -euo pipefail

: "${MYSQL_HOST:?required}"; : "${MYSQL_USER:?required}"; : "${MYSQL_PASSWORD:?required}"
: "${MONGO_HOST:?required}"; : "${MONGO_ADMIN_USER:?required}"; : "${MONGO_ADMIN_PASSWORD:?required}"

mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" < tutor/config/init/mysql-init.sql
mongosh "mongodb://${MONGO_ADMIN_USER}:${MONGO_ADMIN_PASSWORD}@${MONGO_HOST}:27017/admin" tutor/config/init/mongo-init.js

echo "External databases initialized"
