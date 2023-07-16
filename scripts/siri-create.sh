# Script compatible with both zsh and bash shells
#!/usr/bin/env bash

TERRA_DIR="../twingate"
DIRECTORY=".terraform"
MAGENTA='\e[35m'
NO_COLOR='\e[0m'
LABEL="siri-create.sh"
printf "${MAGENTA}==${LABEL}${NO_COLOR}\n"

cd ${TERRA_DIR}

if [ -d "$DIRECTORY" ]; then
  echo $(printf "${MAGENTA} Skipping TERRAFORM INIT, $DIRECTORY directory already exists.${NO_COLOR}")
else
  terraform init -input=false # initialize the working directory
fi

terraform plan -out=tfplan  # create a plan and save it to the local file tfplan

terraform apply tfplan # apply the plan stored in the file `tfplan`

rm tfplan # delete plan file

echo $(printf "${MAGENTA}Apply complete! Resources: 0 added, 0 changed, 0 destroyed.${NO_COLOR}")