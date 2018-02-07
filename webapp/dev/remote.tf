terraform {
  backend "s3" {
    bucket = "jbga-demo-tfstates"
    key    = "lab/webapp.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "coreinfra" {
  backend = "s3"

  config {
    bucket = "jbga-demo-tfstates"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-1"
  }
}
