provider "aws" {}

# Create a new instance of the latest builded ami with packer

resource "aws_elb" "web_elb" {
  name            = "web-elb"
  subnets         = ["${data.terraform_remote_state.coreinfra.subnets}"]
  security_groups = ["${aws_security_group.allow_http.id}"]

  ## Loadbalancer configuration

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

resource "aws_launch_configuration" "web" {
  name            = "launch-configuration-<TRAVIS_COMMIT>"
  image_id        = "${var.ami_id}"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.allow_http.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name                 = "web-asg-<TRAVIS_COMMIT>"
  launch_configuration = "${aws_launch_configuration.web.name}"
  load_balancers       = ["${aws_elb.web_elb.id}"]
  vpc_zone_identifier  = ["${data.terraform_remote_state.coreinfra.subnets}"]
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  health_check_type         = "ELB"
  health_check_grace_period = "300"
  wait_for_elb_capacity     = 1

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http trafic"
  vpc_id      = "${data.terraform_remote_state.coreinfra.vpc_id}"

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

output "elb_dns" {
  value = ["${aws_elb.web_elb.dns_name}"]
}

variable "ami_id" {}
