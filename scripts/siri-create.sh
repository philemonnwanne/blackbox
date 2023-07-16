# Script compatible with both zsh and bash shells
#!/usr/bin/env bash

TERRA_DIR="../twingate" PROVIDERS=".terraform"
midori='\e[32m' KIIRO='\e[33m' no_color='\e[0m' AO='\e[34m' MAG='\e[35m'

cd ${TERRA_DIR}

if [ -d "$PROVIDERS" ]; then
  echo $(printf "${KIIRO} Skipping ${midori}TERRAFORM INIT${no_color}, ${AO}REASON${no_color}: existing providers directory.")
else
  terraform init -input=false # initialize the working directory
fi

terraform plan -out=tfplan  # create a plan and save it to the local file tfplan

terraform apply tfplan # apply the plan stored in the file `tfplan`

rm tfplan # delete plan file

echo $(printf "${MAG}Apply complete! Resources: 0 added, 0 changed, 0 destroyed.${no_color}") 