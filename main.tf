# Cria um par de chaves SSH para acesso à instância EC2
resource "aws_key_pair" "deployer" {
  key_name   = "minha-chave-ec2"
  public_key = file("${path.module}/../minha-chave-ec2.pem.pub")
}
# Define o provedor AWS e a versão mínima
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


# Configura o provedor AWS usando a região definida na variável
provider "aws" {
     user_data                   = <<-EOF
       #!/bin/bash
       set -e
       # Cria e executa o script de instalação do code-server
       cat > /tmp/install-code-server.sh <<'CODESERVER'
  #!/bin/bash

  # Parar a execução se um comando falhar
  set -e

}

  # PASSO 1: ATUALIZAR O SISTEMA

# Cria uma sub-rede pública dentro da VPC
resource "aws_subnet" "main" {

  # PASSO 2: INSTALAR O CODE-SERVER
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"

  # PASSO 3: CONFIGURAR O SERVIÇO PARA ACESSO EXTERNO
  # Modifica o serviço do systemd para garantir que o code-server escute em 0.0.0.0
  # Isso garante que ele seja acessível pelo IP público da EC2.
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {

  # PASSO 4: INICIAR E HABILITAR O SERVIÇO
    Name = "vscode-server-subnet"
  }

  # Pequena pausa para garantir que o arquivo de configuração seja gerado
}


  # PASSO 5: EXIBIR INFORMAÇÕES DE ACESSO
# Obtém as zonas de disponibilidade disponíveis na região

  # Obter o IP Público da instância
  PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

  # Obter a senha do arquivo de configuração
  CS_PASSWORD=$(cat ~/.config/code-server/config.yaml | grep password: | awk '{print $2}')

data "aws_availability_zones" "available" {}

# Cria um Internet Gateway para permitir acesso à internet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "vscode-server-igw"
  }
}

  CODESERVER
       chmod +x /tmp/install-code-server.sh
       /tmp/install-code-server.sh
       # Cria e executa o script de instalação do Nginx proxy
       cat > /tmp/install-nginx-proxy.sh <<'NGINXPROXY'
  #!/bin/bash
  set -e
  # Instala Nginx
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ $ID == "amzn"* ]]; then
      yum install -y nginx
      systemctl enable nginx
      systemctl start nginx
    elif [[ $ID == "ubuntu"* ]]; then
      apt-get update && apt-get install -y nginx
      systemctl enable nginx
      systemctl start nginx
    fi
  fi
  # Configura proxy reverso para code-server
  cat <<EOF2 > /etc/nginx/sites-available/code-server
  server {
      listen 80 default_server;
      server_name _;
      location / {
          proxy_pass http://localhost:8080/;
          proxy_set_header Host $host;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection upgrade;
          proxy_set_header Accept-Encoding gzip;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
      }
  }
  EOF2
  # Ativa configuração no Ubuntu
  if [ -d /etc/nginx/sites-enabled ]; then
    ln -sf /etc/nginx/sites-available/code-server /etc/nginx/sites-enabled/code-server
  fi
  # Remove default do Ubuntu
  if [ -f /etc/nginx/sites-enabled/default ]; then
    rm -f /etc/nginx/sites-enabled/default
  fi
  # Ativa configuração no Amazon Linux
  if [ -d /etc/nginx/conf.d ]; then
    cp /etc/nginx/sites-available/code-server /etc/nginx/conf.d/code-server.conf
  fi
  # Reinicia Nginx
  systemctl restart nginx
  NGINXPROXY
       chmod +x /tmp/install-nginx-proxy.sh
       /tmp/install-nginx-proxy.sh
     EOF
# Cria uma tabela de rotas para a sub-rede pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "vscode-server-rt"
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

# Cria a instância EC2 e instala o code-server automaticamente
resource "aws_instance" "example" {
  root_block_device {
    volume_size = 250
    volume_type = "gp3"
    delete_on_termination = true
  }
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.open_all.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name
   user_data                   = <<-EOF
     #!/bin/bash
     set -e
     # Baixa e executa o script de instalação do code-server
     curl -fsSL https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPOSITORIO/main/scripts/install-code-server.sh -o /tmp/install-code-server.sh
     chmod +x /tmp/install-code-server.sh
     /tmp/install-code-server.sh
     # Baixa e executa o script de instalação do Nginx proxy
     curl -fsSL https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPOSITORIO/main/scripts/install-nginx-proxy.sh -o /tmp/install-nginx-proxy.sh
     chmod +x /tmp/install-nginx-proxy.sh
     /tmp/install-nginx-proxy.sh
   EOF
  tags = {
    Name = "vscode-server-instance"
  }
}
