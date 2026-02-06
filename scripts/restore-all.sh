#!/usr/bin/env bash
set -euo pipefail

: "${BACKUP_DIR:?required}"
: "${MYSQL_HOST:?required}"; : "${MYSQL_USER:?required}"; : "${MYSQL_PASSWORD:?required}"; : "${MYSQL_DB:=openedx}"
: "${MONGO_URI:?required}"

mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DB" < "$BACKUP_DIR/mysql.sql"
mongorestore --uri "$MONGO_URI" "$BACKUP_DIR/mongo"

echo "Restore completed from $BACKUP_DIR"
