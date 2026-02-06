# Troubleshooting Guide

## Tutor cannot connect to MySQL

- Verify SG allows EKS node SG -> RDS:3306
- Check credentials in `k8s/openedx/secrets-external-services.yaml`
- Confirm RDS endpoint resolves from pod:

```bash
kubectl run -n openedx dnscheck --rm -it --image=busybox -- nslookup <rds-endpoint>
```

## MongoDB auth errors

- Confirm users and roles in MongoDB
- Ensure URI/authSource matches configured DB
- Verify EKS SG to Mongo:27017
- If user creation failed, use SSM to recreate the `openedx` user:

```bash
aws ssm send-command --cli-input-json file://scripts/ssm-mongo-fix.json
```

## DOC_STORE_CONFIG is null

- Patch `DOC_STORE_CONFIG` and re-apply the Tutor configmap:

```bash
python3 scripts/patch-docstore.py
kubectl -n openedx apply -k /home/ubuntu/.local/share/tutor/env
```

## Duplicate column errors during `manage.py migrate`

- If `xapi` migrations report duplicate columns, fake `xapi` migrations once and re-run:

```bash
kubectl -n openedx exec deploy/lms -- /bin/sh -c "cd /openedx/edx-platform && python manage.py lms migrate xapi --fake"
kubectl -n openedx exec deploy/lms -- /bin/sh -c "cd /openedx/edx-platform && python manage.py lms migrate"
```

## Ingress admission rejects `server-snippet`

- The ingress controller in this cluster has snippet annotations disabled.
- Remove the `nginx.ingress.kubernetes.io/server-snippet` annotation from `k8s/openedx/ingress.yaml`.
## Ingress 502/504

- Check backend pod readiness
- Validate ingress backend service names
- Review ingress controller logs

## HPA not scaling

- Ensure metrics-server installed
- Verify CPU/memory requests set on deployments
- Run load test and inspect HPA events

## CloudFront returns 403

- Confirm origin host header rules
- Validate WAF rules are not over-blocking
- Check ACM cert in `us-east-1` for CloudFront aliases

## CloudFront creation fails with “account must be verified”

- This is an AWS account limitation for CloudFront on new/unverified accounts.
- Open AWS Support Center and request account verification for CloudFront, then re-run:

```bash
terraform apply
```

