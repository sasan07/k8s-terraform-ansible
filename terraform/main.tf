provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "k8s_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "K8S-VPC"
  }
}

resource "aws_subnet" "k8s_subnet" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "K8S-Subnet"
  }
}

resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id

  tags = {
    Name = "K8S-IGW"
  }
}

resource "aws_route_table" "k8s_rt" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_igw.id
  }

  tags = {
    Name = "K8S-Route-Table"
  }
}

resource "aws_route_table_association" "k8s_rta" {
  subnet_id      = aws_subnet.k8s_subnet.id
  route_table_id = aws_route_table.k8s_rt.id
}


resource "aws_security_group" "k8s_sg" {
  name   = "K8S-All-Traffic"
  vpc_id = aws_vpc.k8s_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "K8S-All-Traffic-SG"
  }
}

locals {
  nodes = {
    "k8s-master"   = "t2.medium"
    "k8s-worker-1" = "t2.medium"
    "k8s-worker-2" = "t2.medium"
    "k8s-worker-3" = "t2.medium"
  }
}

resource "aws_instance" "node" {
  for_each               = local.nodes
  ami                    = "ami-0f8a61b66d1accaee"
  instance_type          = each.value
  subnet_id              = aws_subnet.k8s_subnet.id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  key_name               = "prtprt"

 

  tags = { Name = each.key }
}

output "public_ips" {
  value = { for k, v in aws_instance.node : k => v.public_ip }
}
