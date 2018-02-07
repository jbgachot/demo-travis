#### Travis CI demo

1) Edit 00_vpc/main.tf and webapp/dev/remote.tf and change bucket to match your tfstate bucket
2) Apply 00_vpc for VPC initialization
3) Edit packer/webapp.json and change subnet_id and vpc_id to match terraform output of previous step 

In travis make sure to enable repo and add followings "Environment Variables"
```
AWS_DEFAULT_REGION
AWS_REGION
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

4) For the purpose of this demo, you can edit version number of web application inside packer/scripts/config.sh
