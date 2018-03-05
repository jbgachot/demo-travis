provider "aws" {
  region = "eu-west-1"
}

terraform {
 backend "s3" {
    bucket = "<TERRAFORM_DEMO_BUCKET>"
    key    = "lab/terraform.tfstate"
    region = "eu-west-1"
  }
}

#################
# REMOTE STATES #
#################

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "<TERRAFORM_DEMO_BUCKET>"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-1"
  }
}

#############
# RESOURCES #
#############

resource "aws_launch_configuration" "web" {
  name_prefix = "web_travis_demo_"
  image_id = "${var.ami_id}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.allow_http.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name = "web_travis_demo_${aws_launch_configuration.web.name}"
  min_size = "1"
  max_size = "2"
  min_elb_capacity = "1"
  launch_configuration = "${aws_launch_configuration.web.id}"
  health_check_type = "EC2"
  load_balancers = ["${aws_elb.web_elb.id}"]
  termination_policies = ["OldestLaunchConfiguration"]
  vpc_zone_identifier = ["${data.terraform_remote_state.vpc.subnets}"]
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "web_elb" {
  name            = "web-elb"
  subnets         = ["${data.terraform_remote_state.vpc.subnets}"]
  security_groups = ["${aws_security_group.allow_http.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 2
    target              = "HTTP:80/"
    interval            = 10
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http trafic"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###########
# OUTPUTS #
###########

output "elb_dns" {
  value = ["${aws_elb.web_elb.dns_name}"]
}

variable "ami_id" {}
