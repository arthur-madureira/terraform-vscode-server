#!/bin/bash

# Parar a execução se um comando falhar
set -e

echo "--- Iniciando a instalação do Nginx ---"

# PASSO 1: ATUALIZAR O SISTEMA
echo "[1/4] Atualizando pacotes do sistema..."
sudo apt-get update
sudo apt-get upgrade -y

# PASSO 2: INSTALAR O NGINX
echo "[2/4] Instalando o Nginx..."
sudo apt-get install nginx -y

# PASSO 3: CONFIGURAR O FIREWALL LOCAL (UFW)
# O UFW pode vir desativado por padrão, mas é uma boa prática adicionar a regra.
# Lembre-se que o Security Group da AWS também precisa permitir a porta 80.
echo "[3/4] Configurando o firewall para permitir tráfego na porta 80 (HTTP)..."
sudo ufw allow 'Nginx HTTP'

# PASSO 4: HABILITAR E VERIFICAR O SERVIÇO
echo "[4/4] Habilitando e iniciando o serviço Nginx..."
sudo systemctl enable nginx
sudo systemctl start nginx

# Obter o IP Público da instância para exibir ao usuário
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

echo "---------------------------------------------------------"
echo "✅ Nginx instalado e configurado com sucesso!"
echo ""
echo "Para testar, acesse o endereço abaixo no seu navegador:"
echo "   URL: http://$PUBLIC_IP"
echo ""
echo "Você deve ver a página de boas-vindas do Nginx."
echo "---------------------------------------------------------"