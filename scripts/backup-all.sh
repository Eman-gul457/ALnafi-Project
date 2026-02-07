#!/usr/bin/env bash
# Expected runtime: Linux host/EC2 with access to external databases and S3 (if configured).
set -euo pipefail

BACKUP_DIR=${BACKUP_DIR:-/tmp/openedx-backups/$(date +%F-%H%M%S)}
mkdir -p "$BACKUP_DIR"

: "${MYSQL_HOST:?required}"; : "${MYSQL_USER:?required}"; : "${MYSQL_PASSWORD:?required}"; : "${MYSQL_DB:=openedx}"
: "${MONGO_URI:?required}"
: "${REDIS_HOST:?required}"
: "${PV_VOLUME_ID:?required}"
: "${AWS_REGION:?required}"

mysqldump -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DB" > "$BACKUP_DIR/mysql.sql"
mongodump --uri "$MONGO_URI" --out "$BACKUP_DIR/mongo"

aws elasticache describe-replication-groups --region "$AWS_REGION" > "$BACKUP_DIR/redis-replgroup.json"
aws ec2 create-snapshot --volume-id "$PV_VOLUME_ID" --description "openedx-pv-backup" --region "$AWS_REGION" > "$BACKUP_DIR/pv-snapshot.json"

# OpenSearch snapshot: requires repository pre-configured in domain
if [[ -n "${OPENSEARCH_ENDPOINT:-}" ]]; then
  curl -sS -XPUT "https://${OPENSEARCH_ENDPOINT}/_snapshot/openedx_repo/snap-$(date +%s)?wait_for_completion=true" > "$BACKUP_DIR/opensearch-snapshot.json" || true
fi

echo "Backup completed at $BACKUP_DIR"
