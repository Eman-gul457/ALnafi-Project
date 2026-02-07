
# OpenEdX on AWS EKS - Technical Assessment Submission

Production-grade OpenEdX LMS/CMS deployment on **AWS EKS** using **Tutor + tutor-k8s**, with externalized data services, Nginx ingress, CloudFront + WAF, autoscaling, observability, backups, and operational runbooks.

Target URL: `https://lms.blackmode.io`

## 1. Scope Alignment With Assessment

This repository implements the mandatory requirements:

- AWS EKS for Kubernetes control and workloads
- OpenEdX deployment via Tutor (latest stable) and `tutor-k8s`
- Dedicated Kubernetes namespace isolation
- Externalized data services (outside Kubernetes):
  - MySQL (Amazon RDS)
  - MongoDB (EC2 self-managed MongoDB, or managed alternative on AWS)
  - Elasticsearch-compatible engine (Amazon OpenSearch)
  - Redis (Amazon ElastiCache)
- Nginx ingress as reverse proxy (replacing Caddy edge role)
- TLS termination and HTTP/2 at ingress/load balancer edge
- CloudFront CDN + AWS WAF integration
- PV/PVC for uploads/media
- HPA for LMS/CMS
- Monitoring and logging stack
- Backup/restore automation for data services and persistent storage
- Health probes and troubleshooting guide

## 2. Repository Structure

```text
openedx-eks-assessment/
  infra/terraform/
    envs/prod/
    modules/
      network/
      eks/
      security/
  k8s/
    ingress-nginx/
    openedx/
    monitoring/
  tutor/
    config/
  scripts/
  docs/
  diagrams/
  loadtest/
```

## 3. High-Level Architecture

1. User request enters CloudFront at `lms.blackmode.io`
2. AWS WAF inspects and filters requests (rate limiting + managed rules)
3. CloudFront forwards dynamic traffic to AWS Load Balancer (ingress-nginx service)
4. Nginx ingress routes traffic to OpenEdX LMS/CMS services in EKS
5. OpenEdX services use external data backends (RDS, MongoDB, OpenSearch, ElastiCache)
6. Static assets cached globally by CloudFront
7. Prometheus/Grafana scrape cluster and application metrics

See:
- `diagrams/architecture.mmd`
- `diagrams/network-flow.mmd`

## 4. Prerequisites

- AWS account with IAM permissions for VPC/EKS/RDS/EC2/ElastiCache/OpenSearch/WAF/CloudFront/Route53
- AWS CLI v2 configured
- Terraform >= 1.7
- kubectl >= 1.30
- Helm >= 3.15
- Tutor (latest stable)
- `tutor-k8s` plugin
- `k6` for load testing

## 5. End-to-End Deployment

### Step 1: Provision AWS infrastructure

```bash
cd infra/terraform/envs/prod
cp terraform.tfvars.example terraform.tfvars
# edit values (domain, CIDRs, instance sizes, etc.)
terraform init
terraform plan
terraform apply -auto-approve
```

Outputs include EKS cluster name, ingress endpoint, CloudFront distribution domain, and database endpoints.

### Step 2: Configure kube access and install ingress-nginx

```bash
aws eks update-kubeconfig --region <aws_region> --name <cluster_name>
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
kubectl apply -f ../../../k8s/ingress-nginx/namespace.yaml
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx \
  -f ../../../k8s/ingress-nginx/values.yaml
```

### Step 3: Install monitoring stack

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f ../../../k8s/monitoring/values.yaml
```

### Step 4: Prepare Tutor for Kubernetes and external services

```bash
./scripts/tutor-bootstrap.sh
./scripts/tutor-configure-external-services.sh
```

Then apply:

```bash
tutor config save
tutor k8s init
tutor k8s upgrade --namespace openedx
```

### Step 4.1: MongoDB doc store config and migrations (required for first boot)

If `DOC_STORE_CONFIG` is still null, patch it and re-apply the Tutor configmap:

```bash
python3 scripts/patch-docstore.py
kubectl -n openedx apply -k /home/ubuntu/.local/share/tutor/env
```

If MongoDB auth was not created correctly on the EC2 instance, use the SSM helper:

```bash
aws ssm send-command --cli-input-json file://scripts/ssm-mongo-fix.json
```

Run migrations (and if duplicate xapi columns appear, fake xapi migrations once):

```bash
kubectl -n openedx exec deploy/lms -- /bin/sh -c "cd /openedx/edx-platform && python manage.py lms migrate xapi --fake"
kubectl -n openedx exec deploy/lms -- /bin/sh -c "cd /openedx/edx-platform && python manage.py lms migrate"
```

### Step 5: Apply ingress and autoscaling resources

```bash
kubectl apply -f ../../../k8s/openedx/namespace.yaml
kubectl apply -f ../../../k8s/openedx/secrets-external-services.yaml
kubectl apply -f ../../../k8s/openedx/ingress.yaml
kubectl apply -f ../../../k8s/openedx/hpa-lms.yaml
kubectl apply -f ../../../k8s/openedx/hpa-cms.yaml
kubectl apply -f ../../../k8s/openedx/pvc-uploads.yaml
kubectl apply -f ../../../k8s/openedx/probes-patch.yaml
```

### Step 6: DNS and HTTPS finalization

- Create Route53 (or DNS provider) CNAME:
  - `lms.blackmode.io` -> CloudFront distribution domain
- Validate ACM certificate in `us-east-1` for CloudFront
- Confirm:
  - `https://lms.blackmode.io`

Note: until a real domain is provided, ingress uses a self-signed TLS secret for `lms.blackmode.io`.

## 6. Evidence Collection Checklist

Capture these for submission:

- EKS nodes/pods healthy (`kubectl get nodes,pods -A`)
- OpenEdX LMS page at `https://lms.blackmode.io`
- WAF WebACL associated with CloudFront
- CloudFront behaviors and cache metrics
- External DB connectivity from app logs
- HPA scaling events during load test
- Prometheus and Grafana dashboards
- Backup execution logs and sample restore

## 7. Load Testing (HPA Proof)

```bash
k6 run loadtest/lms-smoke.js
kubectl get hpa -n openedx -w
```

## 8. Backup and Restore

Use:

- `scripts/backup-all.sh`
- `scripts/restore-all.sh`

Includes:

- MySQL dump/restore
- MongoDB dump/restore
- OpenSearch snapshot trigger
- Redis RDB backup copy (or managed snapshot trigger)
- EBS snapshot for PV volume

## 9. Troubleshooting

See `docs/troubleshooting.md`.

## 10. Security Notes

- No hardcoded secrets in git
- Secrets injected via Kubernetes secrets and/or AWS Secrets Manager
- Network policies and SG restrictions enforce least privilege
- WAF managed rules + custom rate limits

## 11. Bonus Additions Included

- GitHub Actions pipeline template
- GitOps-ready manifest layout
- Cost and quota recommendations in docs

## 12. Submission

- Push repo to GitHub
- Attach screenshots in `docs/evidence/`
- Email links and evidence package before **9 February 2026**




\n## TLS (Let\u2019s Encrypt)

We use cert-manager with a ClusterIssuer (letsencrypt-prod) to issue and auto-renew TLS for lms.blackmode.io when CloudFront is blocked by account verification.




## Professional landing content

A custom Al Nafi landing page is applied using a comprehensive theme (see 	utor/themes/alnafi/).

