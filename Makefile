AWS_EKS_CLUSTER_NAME=hackathon-eks-cluster
AWS_SQS_NOTIFICATION_ARN=arn:aws:sqs:us-east-1:905417995957:video-status-notification

# Looks at comments using ## on targets and uses them to produce a help output.
.PHONY: help
help: ALIGN=22
help: ## Print this message
	@echo "Usage: make <command>"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  make \033[1m%-$(ALIGN)s\033[0m - %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: tf-init
tf-init: ## Initialize Terraform
	@echo  "🟢 Initializing Terraform..."
	@cd terraform && terraform init

.PHONY: tf-validate
tf-validate: ## Validate Terraform configuration
	@echo  "🟢 Validating Terraform configuration..."
	@cd terraform && terraform validate

.PHONY: tf-plan
tf-plan: ## Show Terraform plan and save to file
	@echo  "🟢 Showing Terraform plan..."
	@echo "Using AWS_SQS_NOTIFICATION_ARN: $(AWS_SQS_NOTIFICATION_ARN)"
	@cd terraform && terraform plan -out=tfplan -var "notification_queue_arn=$(AWS_SQS_NOTIFICATION_ARN)"

.PHONY: tf-apply
tf-apply: ## Apply Terraform from saved plan
	@echo  "🟢 Applying Terraform..."
	@echo "Using AWS_SQS_NOTIFICATION_ARN: $(AWS_SQS_NOTIFICATION_ARN)"
	@cd terraform && terraform apply -input=false -auto-approve tfplan

.PHONY: tf-apply-direct
tf-apply-direct: ## Apply Terraform directly (without plan file)
	@echo  "🟢 Applying Terraform directly..."
	@echo "Using AWS_SQS_NOTIFICATION_ARN: $(AWS_SQS_NOTIFICATION_ARN)"
	@cd terraform && terraform apply -var "notification_queue_arn=$(AWS_SQS_NOTIFICATION_ARN)" -input=false -auto-approve

.PHONY: tf-destroy
tf-destroy: ## Destroy Terraform resources
	@echo  "🔴 Destroying Terraform resources..."
	@echo "Using AWS_SQS_NOTIFICATION_ARN: $(AWS_SQS_NOTIFICATION_ARN)"
	@cd terraform && terraform destroy -var "notification_queue_arn=$(AWS_SQS_NOTIFICATION_ARN)" -auto-approve
