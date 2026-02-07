#!/usr/bin/env bash
# Expected runtime: Linux host/EC2 with kubectl configured for the target EKS cluster.
set -euo pipefail

kubectl apply -f k8s/openedx/namespace.yaml
kubectl apply -f k8s/openedx/secrets-external-services.yaml
kubectl apply -f k8s/openedx/pvc-uploads.yaml

tutor k8s init
tutor k8s upgrade --namespace openedx

kubectl apply -f k8s/openedx/ingress.yaml
kubectl apply -f k8s/openedx/hpa-lms.yaml
kubectl apply -f k8s/openedx/hpa-cms.yaml

echo "Deployment completed"
