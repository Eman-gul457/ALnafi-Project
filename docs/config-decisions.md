# Configuration Decisions and Rationale

- **EKS on private subnets**: reduces direct exposure and improves security posture.
- **Nginx ingress**: selected as reverse proxy replacement for Caddy edge function, with mature annotations and ALB/NLB support.
- **External data services**: stateful workloads remain outside K8s for better durability and managed operations.
- **CloudFront + WAF**: global acceleration and threat filtering before origin.
- **CloudFront origin policy**: configured as HTTP to the ingress for compatibility during initial rollout; TLS is terminated at CloudFront and ingress supports TLS for direct access.

CDN & TLS Termination Decision:
CloudFront and AWS WAF were originally part of the target production architecture; however, due to AWS service access restrictions encountered during the deployment window, CloudFront could not be provisioned at this stage. To ensure secure and uninterrupted access to the OpenEdX platform, HTTPS termination is implemented directly at the Kubernetes Nginx Ingress layer using publicly trusted Let’s Encrypt certificates issued via cert-manager. This approach removes browser security warnings and enables valid TLS encryption while preserving the intended ingress architecture. CloudFront and WAF remain documented as a future enhancement for production hardening.

Note: No CloudFront distribution is currently provisioned; the WAF resource exists but is not attached to any distribution and remains part of the future target state.
- **HPA on LMS/CMS**: elasticity for variable learner traffic and enrollment spikes.
- **PV/PVC for uploads**: decouples media from pod lifecycle.
- **Prometheus/Grafana**: operational observability and autoscaling diagnostics.
- **Backups**: combines logical dumps and volume snapshots for layered recovery.



\n## TLS (Let\u2019s Encrypt)

We use cert-manager with a ClusterIssuer (letsencrypt-prod) to issue and auto-renew TLS for lms.blackmode.io when CloudFront is blocked by account verification.


