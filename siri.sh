#!/bin/bash

cd ./terraform/env/dev

# terraform init

# terraform apply -auto-approve

terraform init -input=false # initialize the working directory

terraform plan -out=tfplan -input=false # create a plan and save it to the local file tfplan

terraform apply -input=false tfplan # apply the plan stored in the file `tfplan`
