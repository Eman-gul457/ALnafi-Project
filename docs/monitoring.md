# Monitoring and Alerting

- Install `kube-prometheus-stack` with `k8s/monitoring/values.yaml`
- Dashboard coverage:
  - Node CPU/memory
  - Pod restarts
  - LMS/CMS request latency and error rate
  - Nginx ingress request saturation
  - HPA replica behavior
- Alert examples:
  - Pod crashloop > 5m
  - 5xx > 2% for 10m
  - DB connectivity probe failures
  - PVC storage > 85%
