#!/bin/sh
set -e

PACKER_DIR="$TRAVIS_BUILD_DIR/packer"
TERRAFORM_DIR="$TRAVIS_BUILD_DIR/terraform"

# Preset files for the purpose of the demo
cd $TRAVIS_BUILD_DIR
sed -i "s#<TRAVIS_JOB_ID>#$TRAVIS_JOB_ID#" app/index.html
sed -i "s#<TRAVIS_COMMIT>#$TRAVIS_COMMIT#" app/index.html
sed -i "s#<APP_VERSION>#$APP_VERSION#" app/index.html
cd $TERRAFORM_DIR
sed -i "s#<TERRAFORM_DEMO_BUCKET>#$TERRAFORM_DEMO_BUCKET#" vpc/main.tf
sed -i "s#<TERRAFORM_DEMO_BUCKET>#$TERRAFORM_DEMO_BUCKET#" webapp/main.tf

# Start deploying VPC with terraform
cd $TERRAFORM_DIR/vpc
terraform init
terraform plan
terraform apply

# Replace subnet for packer
terraform output -json subnets | jq '.value[0]'
sed -i "s#<SUBNET_ID>#$(terraform output -json subnets | jq ".value[0]")#" $PACKER_DIR/webapp.json

# Replace vpc for packer
terraform output -json vpc_id | jq '.value'
sed -i "s#<VPC_ID>#$(terraform output -json vpc_id | jq ".value")#" $PACKER_DIR/webapp.json

# Start creating packer's ami
cd $PACKER_DIR
packer build webapp.json | tee /tmp/packer.out
AMI=$(awk -F':' '/(eu|us|ap|sa)-(west|central|east|northeast|southeast)-(1|2): ami-/ {print $2}' /tmp/packer.out |  tr -d '[[:space:]]')

# Start deploying APP with terraform
cd $TERRAFORM_DIR/webapp
terraform init
terraform plan -var ami_id=$AMI
terraform apply -var ami_id=$AMI
