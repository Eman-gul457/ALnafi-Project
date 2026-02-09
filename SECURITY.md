# Security Notes

## TLS and HTTPS
All external traffic to the OpenEdX platform is secured using HTTPS.
TLS termination is handled by the Nginx Ingress Controller using Let’s Encrypt certificates
managed by cert-manager. Certificates are publicly trusted and automatically renewed.

AWS CloudFront and AWS WAF are part of the intended production architecture.
Due to AWS account service access limitations, they could not be enabled during this deployment
and are documented as a future enhancement.

## Secrets Management
Sensitive information such as database credentials is managed using Kubernetes Secrets.
No secrets, passwords, or private keys are stored in source control.

## Network Isolation
The EKS cluster runs inside a private AWS VPC.
External data services are protected using AWS security groups and only allow traffic
from the EKS worker nodes, following the principle of least privilege.
