#### Travis CI demo

1) Edit .travis.yml and setup TERRAFORM_DEMO_BUCKET variable to match your tfstates bucket, edit terraform/vpc/main.tf and setup bucket in s3 backend

In travis make sure to enable repo and add followings secured "Environment Variables" from travis web interface :
```
AWS_DEFAULT_REGION
AWS_REGION
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

4) For the purpose of this demo, you can edit version number of web application inside .travis.yml
