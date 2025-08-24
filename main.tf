# Cria uma VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "code-server-vpc"
  }
}

# Cria um Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "code-server-igw"
  }
}

# Cria uma Subnet pública
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  tags = {
    Name = "code-server-subnet"
  }
}

# Define o provedor AWS e a versão mínima
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region                  = var.aws_region
  shared_credentials_files = ["${path.module}/aws-credentials"]
  profile                 = "default"
}

# Cria um par de chaves SSH para acesso à instância EC2
resource "aws_key_pair" "deployer" {
  key_name   = "minha-chave-ec2"
  public_key = file("${path.module}/../minha-chave-ec2.pem.pub")
}

# Cria uma tabela de rotas para a sub-rede pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "code-server-rt"
  }
}

# Associa a tabela de rotas à sub-rede
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}

# Cria um Security Group que libera todas as portas para qualquer IP (atenção: não recomendado para produção)
resource "aws_security_group" "open_all" {
  name        = "open-all-ports"
  description = "Security group with all ports open (not recommended for production)"
  vpc_id      = aws_vpc.main.id

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
}

# Cria a instância EC2 e copia o script de instalação (não executa)
# Cria a instância EC2 e instala o code-server automaticamente
resource "aws_instance" "example" {
  root_block_device {
    volume_size           = 250
    volume_type           = "gp3"
    delete_on_termination = true
  }
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.open_all.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name

  # Combina os dois scripts em um único user_data
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Executa o script de instalação do code-server
    ${file("${path.module}/scripts/install-code-server.sh")}

    # Executa o script de instalação do Nginx
    ${file("${path.module}/scripts/install-nginx-proxy.sh")}
  EOF

  tags = {
    Name = "vscode-server-instance"
  }
}