terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
  token      = ""
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "tf-vpc"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_internet_gateway_attachment" "attach_gateway" {
  vpc_id              = aws_vpc.vpc.id
  internet_gateway_id = aws_internet_gateway.internet_gateway.id
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/26"
  map_public_ip_on_launch = true
  // availability_zone = ??
  tags = {
    "Name" = "tf-public-subnet-a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.64/26"
  map_public_ip_on_launch = true
  // availability_zone = ??
  tags = {
    "Name" = "tf-public-subnet-b"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.128/26"
  map_public_ip_on_launch = false
  // availability_zone = ??
  tags = {
    "Name" = "tf-private-subnet-a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.192/26"
  map_public_ip_on_launch = false
  // availability_zone = 
  tags = {
    "Name" = "tf-private-subnet-b"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "tf-public-route-table"
  }
}

resource "aws_route" "public_route" {
  depends_on = [
    aws_internet_gateway_attachment.attach_gateway
  ]
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "tf-private-route-table"
  }
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table_association" "public_subnet_a_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_b_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_a_route_table_association" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_b_route_table_association" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.allocation_id
  subnet_id     = aws_subnet.public_subnet_a.id
  tags = {
    "Name" = "tf-nat-gatewat"
  }
}

resource "aws_eip" "elastic_ip" {
  // domain is VPC, but it is set basec on configuration
}

resource "aws_security_group" "instance_security_group" {
  vpc_id      = aws_vpc.vpc.id
  description = "Enable SSH access via port 22"
  ingress = [{
    description      = "Ingress security group description"
    protocol         = "tcp"
    from_port        = 22
    to_port          = 22
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]
}

resource "aws_network_interface" "network_interface" {
  subnet_id       = aws_subnet.public_subnet_a.id
  security_groups = [aws_security_group.instance_security_group.id]

  tags = {
    "Name" = "tf-network-interface"
  }
}

resource "aws_instance" "ec2_instance" {
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  ami                         = "ami-0be2609ba883822ec"
  // key_name = ??
}