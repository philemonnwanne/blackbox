# Script compatible with both zsh and bash shells
#!/usr/bin/env bash

RED='\e[31m'
NO_COLOR='\e[0m'
LABEL="siri-destroy.sh"
printf "${RED}==${LABEL}${NO_COLOR}\n"

cd ../twingate

terraform init -input=false # initialize the working directory

terraform plan -input=false -out=tfplan  # create a plan and save it to the local file tfplan

terraform apply -input=false tfplan # apply the plan stored in the file `tfplan`
