🚀 OpenEdX on AWS EKS — Al Nafi Technical Assessment
---
Live LMS URL: https://lms.blackmode.io
Cloud Platform: AWS (EKS Only)
Deployment Method: Tutor + tutor-k8s
Ingress: Nginx
TLS: Let’s Encrypt via cert-manager
Status: Production-ready deployment

---
1️⃣ Project Overview:
---
This project demonstrates a real production deployment of the OpenEdX Learning Management System on AWS EKS (Kubernetes).
The goal was not just to “make it run”, but to:
- Use AWS-native infrastructure
- Follow enterprise architecture
- Separate application and databases
- Enable security, scalability, and observability
- Document everything clearly
- This repository represents hands-on execution, not theory.

---
2️⃣ What Was Built:
---
- AWS EKS cluster with proper networking
- OpenEdX LMS & CMS running in Kubernetes
- All databases external to Kubernetes
- Nginx Ingress replacing default Caddy
- HTTPS using Let’s Encrypt (cert-manager)
- Horizontal Pod Autoscaling (HPA)
- Load testing to prove autoscaling
- Backup & restore automation (scripts provided)
- Clean documentation & reproducible setup

---

3️⃣ Architecture Summary:
---
1. Users open https://lms.blackmode.io
2. Traffic goes to Nginx Ingress (AWS Load Balancer)
3. Nginx routes requests to OpenEdX LMS/CMS pods
4. OpenEdX connects to external databases:
  - MySQL (RDS)
  - MongoDB (EC2)
  - OpenSearch
  - Redis
5. Kubernetes HPA automatically scales LMS & CMS under load

---
4️⃣ Repository Structure — What Each Folder Does
---
🔹 .github/workflows/
---
ci.yml
Basic CI pipeline structure for validation and automation readiness.

🔹 infra/terraform/
---
Provisioning all AWS infrastructure

- envs/prod/ – Production environment
- network/ – VPC, subnets, routing
- eks/ – EKS cluster & node groups
- security/ – IAM roles, security groups
- mongo-userdata.sh – MongoDB EC2 initialization
- elasticsearch-userdata.sh – OpenSearch setup
- variables.tf / outputs.tf – Terraform inputs & outputs
✅ Shows infrastructure-as-code discipline

🔹 k8s/
---
All Kubernetes manifests
ingress-nginx/
- namespace.yaml – Nginx namespace
- values.yaml – Nginx configuration
openedx/
- namespace.yaml – OpenEdX isolation
- ingress.yaml – Routing & TLS
- clusterissuer-letsencrypt.yaml – HTTPS issuer
- hpa-lms.yaml / hpa-cms.yaml – Autoscaling
- pvc-uploads.yaml – Persistent storage
- probes-patch.yaml – Health checks
- secrets-external-services.yaml – External DB connectivity

🔹 tutor/
---
Tutor configuration for OpenEdX
- config.yml – Core Tutor config
- init/ – DB initialization
- themes/alnafi/ – Custom Al Nafi LMS theme
  - index.html
  - alnafi.css
  - theme.json

🔹 scripts/
---

Operational automation

- deploy-openedx.sh – Full deployment
- backup-all.sh – Backup all databases & volumes
- restore-all.sh – Restore backups
- init-external-dbs.sh – Prepare DBs
- tutor-bootstrap.sh – Install Tutor
- tutor-configure-external-services.sh
- validate.sh – Deployment checks

🔹 loadtest/
---
- lms-smoke.js – k6 load test for autoscaling proof

🔹 docs/
---
Professional documentation
- deployment-guide.md
- config-decisions.md
- monitoring.md
- backup-dr.md
- troubleshooting.md
- evidence-template.md

---

5️⃣ Deployment Steps (What Was Done):
---
Step 1: Provision AWS Infrastructure
```bash
cd infra/terraform/envs/prod
terraform init
terraform plan
terraform apply -auto-approve
```
<img width="1344" height="423" alt="eks-cluster" src="https://github.com/user-attachments/assets/e16f6307-0c48-4d0c-8e3a-768b6617faa6" />

---
<img width="1082" height="233" alt="nodegroup-running" src="https://github.com/user-attachments/assets/58f9ca58-02e5-4459-a65c-e6254c371d66" />

---

<img width="960" height="445" alt="vpc-networking" src="https://github.com/user-attachments/assets/332ff908-5b4a-4f94-b1b0-d956087777c4" />

---
Step 2: Connect to EKS
---
```bash
aws eks update-kubeconfig --region ap-south-1 --name openedx-prod
```

<img width="731" height="113" alt="kubectl-nodes" src="https://github.com/user-attachments/assets/f93264fc-db25-43bb-bdb3-1e0802a96a68" />

---
Step 3: Install Nginx Ingress
---
```bash
kubectl apply -f k8s/ingress-nginx/namespace.yaml
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx -f k8s/ingress-nginx/values.yaml
```
<img width="734" height="538" alt="ingress-tls" src="https://github.com/user-attachments/assets/3ffb19e1-60e8-4df1-a2f7-1d6c81f295bd" />

---
Step 4: Enable HTTPS (cert-manager)
---
```bash
kubectl apply -f k8s/openedx/clusterissuer-letsencrypt.yaml
kubectl get certificate -A
```
<img width="662" height="104" alt="cert-manager-cert" src="https://github.com/user-attachments/assets/c719fb31-600b-42f3-b5d3-281099a47aa6" />

---
Step 5: Deploy OpenEdX
---
```bash
tutor config save
tutor k8s upgrade
```
<img width="647" height="104" alt="openedx-namespace" src="https://github.com/user-attachments/assets/4a7db5a1-7d5f-44d9-92da-d40f790c92c5" />

---
<img width="755" height="458" alt="kubectl-pods-all-ns" src="https://github.com/user-attachments/assets/483b2602-7ada-4c11-bf65-23241670e104" />

---
Step 6: Apply Autoscaling
---
```bash
kubectl apply -f k8s/openedx/hpa-lms.yaml
kubectl apply -f k8s/openedx/hpa-cms.yaml
```
# Before Load:

<img width="969" height="183" alt="hpa-before-load" src="https://github.com/user-attachments/assets/a92e7d09-d3b8-4c9f-b2ef-0682b1a92ef6" />

---
# Load Testing
```bash
k6 run loadtest/lms-smoke.js
```

<img width="912" height="429" alt="hpa-apply-load" src="https://github.com/user-attachments/assets/e916bd20-eaf2-455d-aff8-3f8acda48bec" />

---
# During Load:

<img width="739" height="466" alt="hpa-during-load" src="https://github.com/user-attachments/assets/9977ddcf-cf65-4195-b234-112d3d4a877a" />

---
# After Load:

<img width="887" height="315" alt="hpa-after-load" src="https://github.com/user-attachments/assets/45e98792-1583-49b8-b676-64073dcbcb2c" />

---
Step 7: Apply Al Nafi Theme
---
```bash
kubectl -n openedx rollout restart deploy/lms
```

<img width="1295" height="678" alt="LMS-landing-page(1)" src="https://github.com/user-attachments/assets/5fa07073-1a7c-4185-9c3c-b106cb4a7a21" />

---

6️⃣ CloudFront & WAF (Architectural Note)
---
AWS CloudFront and WAF are part of the target enterprise architecture and are fully documented in this repository.
Due to AWS account service access limitations, they could not be provisioned during execution.
➡ HTTPS is securely terminated at Nginx Ingress using Let’s Encrypt, which still provides encrypted, production-grade access.

---
