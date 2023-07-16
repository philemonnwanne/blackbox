#!/bin/bash

MAGENTA='\e[35m'
NO_COLOR='\e[0m'
LABEL="siri-create.sh"
printf "${MAGENTA}==${LABEL}${NO_COLOR}\n"

cd ../twingate

terraform plan -input=false -out=tfplan # create a plan and save it to the local file tfplan

terraform destroy -input=false tfplan # apply the plan stored in the file `tfplan`


# terraform plan -destroy -out=tfdestroy

# terraform apply tfdestroy -auto-approve