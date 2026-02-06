# Configuration Decisions and Rationale

- **EKS on private subnets**: reduces direct exposure and improves security posture.
- **Nginx ingress**: selected as reverse proxy replacement for Caddy edge function, with mature annotations and ALB/NLB support.
- **External data services**: stateful workloads remain outside K8s for better durability and managed operations.
- **CloudFront + WAF**: global acceleration and threat filtering before origin.
- **HPA on LMS/CMS**: elasticity for variable learner traffic and enrollment spikes.
- **PV/PVC for uploads**: decouples media from pod lifecycle.
- **Prometheus/Grafana**: operational observability and autoscaling diagnostics.
- **Backups**: combines logical dumps and volume snapshots for layered recovery.
