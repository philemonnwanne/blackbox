VAR_FILE ?= variables.tfvars

apply:
	terraform apply -var-file=${VAR_FILE}
destroy:
	terraform apply -var-file=${VAR_FILE}
terraform:
	terraform plan -var-file=${VAR_FILE}
	terraform apply -var-file=${VAR_FILE}
	