terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" // for most providers: allow minor version updates
    }
  }
}

provider "aws" {
  region = var.region
}

### VPC default existente
data "aws_vpc" "default" {
  default = true
}

### SSH KEY (creada por Terraform)
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "blueprint-terraform-key" {
  key_name   = "blueprint-terraform-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "aws_security_group" "blueprint-sg" {
  name   = "blueprint-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  //ingress {
  //  from_port   = 8000
  //  to_port     = 8000
  //  protocol    = "tcp"
  //  cidr_blocks = [var.allowed_ssh_cidr]
  //}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allowed_ssh_cidr]
  }
}

resource "aws_instance" "server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.blueprint-terraform-key.key_name
  vpc_security_group_ids = [aws_security_group.blueprint-sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-server"
  }
}

resource "aws_s3_bucket" "storage" {
  bucket = "${var.project_name}-storage-${var.expediente}"

  tags = {
    Name = "${var.project_name}-storage"
  }
}
