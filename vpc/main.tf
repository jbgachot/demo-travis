terraform {
  backend "s3" {
    bucket = "jbga-demo-tfstates"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "demo" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "demo_vpc"
  }
}

resource "aws_subnet" "AZa" {
  vpc_id                  = "${aws_vpc.demo.id}"
  cidr_block              = "${var.zonea_cidr}"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = "true"

  tags {
    Name = "demo_subnet_AZa"
  }
}

resource "aws_subnet" "AZb" {
  vpc_id                  = "${aws_vpc.demo.id}"
  cidr_block              = "${var.zoneb_cidr}"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = "true"

  tags {
    Name = "demo_subnet_AZb"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = "${aws_vpc.demo.id}"

  tags {
    Name = "demo_IGW"
  }
}

resource "aws_route_table" "RT" {
  vpc_id = "${aws_vpc.demo.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.IGW.id}"
  }

  tags {
    Name = "demo_RT"
  }
}

resource "aws_route_table_association" "ASSa" {
  subnet_id      = "${aws_subnet.AZa.id}"
  route_table_id = "${aws_route_table.RT.id}"
}

resource "aws_route_table_association" "ASSb" {
  subnet_id      = "${aws_subnet.AZb.id}"
  route_table_id = "${aws_route_table.RT.id}"
}

output "vpc_id" {
  value = "${aws_vpc.demo.id}"
}

output "subnets" {
  value = ["${aws_subnet.AZa.id}","${aws_subnet.AZb.id}"]
}
