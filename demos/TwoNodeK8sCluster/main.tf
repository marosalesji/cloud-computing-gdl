provider "aws" {
  region = var.region
}

### VPC default existente
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

### AMI Amazon Linux 2
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

### SSH KEY (creada por Terraform)
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "k3s" {
  key_name   = "k3s-terraform-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

### Security Group
resource "aws_security_group" "k3s" {
  name   = "k3s-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "-1"
    self     = true
    from_port = 0
    to_port   = 0
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### Controller
resource "aws_instance" "controller" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.large"
  subnet_id              = data.aws_subnet_ids.default.ids[0]
  key_name               = aws_key_pair.k3s.key_name
  vpc_security_group_ids = [aws_security_group.k3s.id]

  user_data = templatefile("user-data-controller.sh", {
    k3s_token = var.k3s_token
  })

  tags = {
    Name = "k3s-controller"
  }
}

### Worker
resource "aws_instance" "worker" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.large"
  subnet_id              = data.aws_subnet_ids.default.ids[0]
  key_name               = aws_key_pair.k3s.key_name
  vpc_security_group_ids = [aws_security_group.k3s.id]

  user_data = templatefile("user-data-worker.sh", {
    controller_ip = aws_instance.controller.private_ip
    k3s_token     = var.k3s_token
  })

  depends_on = [aws_instance.controller]

  tags = {
    Name = "k3s-worker"
  }
}
