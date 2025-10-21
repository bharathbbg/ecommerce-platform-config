.PHONY: tf-init tf-validate tf-plan tf-apply tf-destroy

# Variables
ENV?=staging
TF_VAR_FILE=environments/$(ENV).tfvars

# Terraform commands
tf-init:
	terraform init -backend-config=backend/$(ENV).tfbackend

tf-validate:
	terraform validate

tf-plan:
	terraform plan -var-file=$(TF_VAR_FILE) -out=tfplan

tf-apply:
	terraform apply tfplan

tf-destroy:
	terraform destroy -var-file=$(TF_VAR_FILE) -auto-approve