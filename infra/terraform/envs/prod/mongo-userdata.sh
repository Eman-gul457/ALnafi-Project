#!/bin/bash
set -euo pipefail

apt-get update
apt-get install -y gnupg curl
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-7.0.list
apt-get update
apt-get install -y mongodb-org

cat >/etc/mongod.conf <<EOF
storage:
  dbPath: /var/lib/mongodb
net:
  bindIp: 0.0.0.0
  port: 27017
security:
  authorization: disabled
EOF

systemctl enable mongod
systemctl restart mongod

# Create initial application user while auth is disabled.
mongosh --eval 'use admin; db.createUser({user:"openedx", pwd:"OpenedxMongo2026!", roles:[{role:"readWriteAnyDatabase", db:"admin"}]})' || true
mongosh --eval 'use openedx; db.createCollection("init_marker")' || true

cat >/etc/mongod.conf <<EOF
storage:
  dbPath: /var/lib/mongodb
net:
  bindIp: 0.0.0.0
  port: 27017
security:
  authorization: enabled
EOF

systemctl restart mongod
