#!/usr/bin/env bash
# Expected runtime: Linux host/EC2 with internet access and Python tooling.
set -euo pipefail

echo "[1/4] Installing tutor-k8s plugin"
tutor plugins install k8s || true
tutor plugins enable k8s

echo "[2/4] Enabling required plugins"
tutor plugins enable forum || true
tutor plugins enable mfe || true

echo "[3/4] Copying baseline config"
mkdir -p "$(tutor config printroot)"
cp -f tutor/config/config.yml "$(tutor config printroot)/config.yml"

echo "[4/4] Saving Tutor config"
tutor config save

echo "Tutor bootstrap complete"
