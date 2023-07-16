# Script compatible with both zsh and bash shells
#!/usr/bin/env bash

TERRA_DIR="../twingate"
AKA='\e[31m' NO_COLOR='\e[0m' LABEL="siri-destroy.sh"

printf "💣🔥 ${AKA}${LABEL}${NO_COLOR}\n"

cd ${TERRA_DIR}

terraform plan -destroy -out=tfplan # create a plan and save it to the local file tfplan

terraform apply tfplan # apply the plan stored in the file `tfplan`

rm tfplan # delete plan file