# Backup and DR Strategy

## Backup Frequency

- MySQL: daily full dump + 15-min binlog (RDS automated backups)
- MongoDB: daily dump + weekly EBS snapshot
- OpenSearch: daily snapshot repository policy
- Redis: managed snapshots every 6 hours
- PV: daily EBS snapshot

## Recovery Targets

- RPO: 15 minutes (critical data)
- RTO: 2 hours (service restoration)

## Restore Flow

1. Restore data backends
2. Re-deploy OpenEdX pods
3. Validate migrations and app health
4. Switch traffic after verification
