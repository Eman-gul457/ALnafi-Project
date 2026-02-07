# Security Notes

## TLS Termination

- HTTPS is terminated at the Nginx Ingress Controller using Let’s Encrypt via cert-manager.
- Certificates are publicly trusted and auto‑renewed.
- CloudFront + WAF remain the target architecture but are pending AWS account verification.

## Secrets Management

- Secrets are injected via Kubernetes Secrets.
- External database credentials are not stored in source control.

## Network Isolation

- EKS workloads run in private subnets.
- Data services are isolated with security groups and only accept traffic from EKS nodes.
