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
✔ AWS EKS cluster with proper networking
✔ OpenEdX LMS & CMS running in Kubernetes
✔ All databases external to Kubernetes
✔ Nginx Ingress replacing default Caddy
✔ HTTPS using Let’s Encrypt (cert-manager)
✔ Horizontal Pod Autoscaling (HPA)
✔ Load testing to prove autoscaling
✔ Backup & restore automation (scripts provided)
✔ Clean documentation & reproducible setup

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
