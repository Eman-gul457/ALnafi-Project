#!/usr/bin/env bash
set -euo pipefail

chmod +x scripts/*.sh
terraform fmt -recursive infra/terraform
kubectl apply --dry-run=client -f k8s/openedx/namespace.yaml >/dev/null
kubectl apply --dry-run=client -f k8s/openedx/ingress.yaml >/dev/null
kubectl apply --dry-run=client -f k8s/openedx/hpa-lms.yaml >/dev/null
kubectl apply --dry-run=client -f k8s/openedx/hpa-cms.yaml >/dev/null

echo "Validation checks passed"
