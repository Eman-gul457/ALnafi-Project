# Step-by-Step Deployment Guide

## A. Infrastructure Provisioning

1. Configure `infra/terraform/envs/prod/terraform.tfvars`
2. Apply Terraform
3. Wait for EKS, RDS, Redis, OpenSearch, Mongo EC2, WAF, CloudFront completion

## B. Cluster Bootstrap

1. Update kubeconfig
2. Install ingress-nginx with `k8s/ingress-nginx/values.yaml`
3. Install monitoring stack

## C. Tutor Setup

1. Install Tutor and `tutor-k8s`
2. Run:

```bash
./scripts/tutor-bootstrap.sh
export MYSQL_HOST=...
export MYSQL_USER=...
export MYSQL_PASSWORD=...
export MONGO_HOST=...
export MONGO_USER=...
export MONGO_PASSWORD=...
export ELASTICSEARCH_HOST=...
export REDIS_HOST=...
./scripts/tutor-configure-external-services.sh
```

3. Deploy OpenEdX:

```bash
./scripts/deploy-openedx.sh
```

4. Patch Mongo doc store config (required when using external MongoDB):

```bash
python3 scripts/patch-docstore.py
kubectl -n openedx apply -k /home/ubuntu/.local/share/tutor/env
```

5. Run migrations:

```bash
kubectl -n openedx exec deploy/lms -- /bin/sh -c "cd /openedx/edx-platform && python manage.py lms migrate"
```

If duplicate-column errors appear in `xapi` migrations, run once:

```bash
kubectl -n openedx exec deploy/lms -- /bin/sh -c "cd /openedx/edx-platform && python manage.py lms migrate xapi --fake"
```

## D. DNS, CDN, WAF

1. Validate CloudFront distribution
2. Ensure WAF WebACL attached
3. Point `lms.blackmode.io` CNAME to CloudFront domain
4. Validate HTTPS and HTTP/2:

```bash
curl -I --http2 https://lms.blackmode.io
```

CDN & TLS Termination Decision:
CloudFront and AWS WAF were originally part of the target production architecture; however, due to AWS service access restrictions encountered during the deployment window, CloudFront could not be provisioned at this stage. To ensure secure and uninterrupted access to the OpenEdX platform, HTTPS termination is implemented directly at the Kubernetes Nginx Ingress layer using publicly trusted Let’s Encrypt certificates issued via cert-manager. This approach removes browser security warnings and enables valid TLS encryption while preserving the intended ingress architecture. CloudFront and WAF remain documented as a future enhancement for production hardening.

Note: No CloudFront distribution is currently provisioned; the WAF resource exists but is not attached to any distribution and remains part of the future target state.

## E. Validation

```bash
kubectl get pods -n openedx
kubectl get ingress -n openedx
kubectl get hpa -n openedx
k6 run loadtest/lms-smoke.js
```




We use cert-manager with a ClusterIssuer (letsencrypt-prod) to issue and auto-renew TLS for lms.blackmode.io when CloudFront is blocked by account verification.


