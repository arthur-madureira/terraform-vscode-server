#!/bin/bash

# Parar a execução se um comando falhar
set -e

echo "--- Iniciando a instalação e configuração do code-server ---"

# PASSO 1: ATUALIZAR O SISTEMA
echo "[1/5] Atualizando pacotes do sistema..."
sudo apt-get update
sudo apt-get upgrade -y

# PASSO 2: INSTALAR O CODE-SERVER
echo "[2/5] Baixando e instalando o code-server..."
curl -fsSL https://code-server.dev/install.sh | sh

# PASSO 3: CONFIGURAR O SERVIÇO PARA ACESSO EXTERNO
# Modifica o serviço do systemd para garantir que o code-server escute em 0.0.0.0
# Isso garante que ele seja acessível pelo IP público da EC2.
echo "[3/5] Configurando o serviço para acesso externo..."
sudo sed -i 's|ExecStart=/usr/bin/code-server|ExecStart=/usr/bin/code-server --bind-addr 0.0.0.0:8080|' /lib/systemd/system/code-server@.service
sudo systemctl daemon-reload

# PASSO 4: INICIAR E HABILITAR O SERVIÇO
echo "[4/5] Habilitando e iniciando o serviço code-server..."
sudo systemctl enable --now code-server@$USER

# Pequena pausa para garantir que o arquivo de configuração seja gerado
echo "Aguardando 5 segundos para a inicialização do serviço..."
sleep 5

# PASSO 5: EXIBIR INFORMAÇÕES DE ACESSO
echo "[5/5] Recuperando informações de acesso..."

# Obter o IP Público da instância
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

# Obter a senha do arquivo de configuração
CS_PASSWORD=$(cat ~/.config/code-server/config.yaml | grep password: | awk '{print $2}')

echo "---------------------------------------------------------"
echo "✅ Instalação do code-server concluída com sucesso!"
echo ""
echo "Acesse no seu navegador:"
echo "   URL: http://$PUBLIC_IP:8080"
echo ""
echo "Sua senha é:"
echo "   Senha: $CS_PASSWORD"
echo ""
echo "---------------------------------------------------------"