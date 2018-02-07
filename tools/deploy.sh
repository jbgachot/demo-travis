#!/bin/sh
set -e
cd $TRAVIS_BUILD_DIR/packer
sed -i "s#<TRAVIS_JOB_ID>#$TRAVIS_JOB_ID#" files/index.html
sed -i "s#<TRAVIS_COMMIT>#$TRAVIS_COMMIT#" files/index.html
packer build webapp.json | tee /tmp/packer.out
AMI=$(awk -F':' '/(eu|us|ap|sa)-(west|central|east|northeast|southeast)-(1|2): ami-/ {print $2}' /tmp/packer.out |  tr -d '[[:space:]]')

cd $TRAVIS_BUILD_DIR/webapp/dev
sed -i "s#<TRAVIS_COMMIT>#$TRAVIS_COMMIT#" main.tf
terraform init
terraform plan -var ami_id=$AMI
terraform apply -var ami_id=$AMI
