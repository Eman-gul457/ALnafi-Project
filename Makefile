SHELL := /bin/bash

validate:
	./scripts/validate.sh

terraform-init:
	cd infra/terraform/envs/prod && terraform init

terraform-plan:
	cd infra/terraform/envs/prod && terraform plan

deploy:
	./scripts/deploy-openedx.sh

backup:
	./scripts/backup-all.sh

restore:
	./scripts/restore-all.sh
