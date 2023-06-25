VAR_FILE ?= variables.tf
OUTPUT_FILE ?= tfplan

init:
	terraform init -input=false
plan:
	terraform plan -var-file=${VAR_FILE} -out=${OUTPUT_FILE} -input=false
apply:
	terraform apply -var-file=${VAR_FILE} -out=${OUTPUT_FILE} -input=false
destroy:
	terraform plan -destroy
	terraform apply -destroy -var-file=${VAR_FILE}
terraform-create:
	terraform init -input=false
	terraform plan -var-file=${VAR_FILE} -out=${OUTPUT_FILE} -input=false
	terraform apply -var-file=${VAR_FILE} -out=${OUTPUT_FILE} -input=false
terraform-destroy:
	terraform plan -var-file=${VAR_FILE} -out=${OUTPUT_FILE} -input=false
	terraform apply -destroy -var-file=${VAR_FILE}