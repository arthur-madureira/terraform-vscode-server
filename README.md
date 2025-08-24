# Acesso via domínio e Nginx

O projeto instala e configura automaticamente o Nginx como proxy reverso na instância EC2. Isso permite acessar o code-server diretamente pelo seu domínio (ou IP) na porta padrão HTTP (80), sem precisar informar :8080 no navegador.

**Como funciona:**
- O Nginx recebe as conexões na porta 80 e repassa (proxy) para o code-server, que roda internamente na porta 8080.
- Assim, basta acessar `http://seudominio.com` ou `http://<ip-da-ec2>` para abrir o VS Code Web.

**Importante:**
- Se usar domínio, aponte o registro A do seu DNS para o IP público da EC2.
- Para HTTPS, é necessário configurar um certificado SSL no Nginx (posso ajudar se desejar).
# Segurança e arquivos ignorados

Este projeto inclui um arquivo `.gitignore` que impede que arquivos sensíveis e temporários sejam versionados no Git. Entre eles:

- Arquivos de estado do Terraform (`*.tfstate`, `.terraform/`)
- Arquivos de credenciais (`aws-credentials`, `.env`)
- Chaves SSH (`*.pem`, `*.pem.pub`)
- Logs (`*.log`)
- Configurações locais e backups (`.vscode/`, `*~`, `*.bak`)

**Nunca compartilhe ou faça commit desses arquivos em repositórios públicos.**

Se precisar versionar variáveis de ambiente para outros membros do time, use arquivos de exemplo como `.env.example` sem dados sensíveis.
# Serviços criados por este projeto (explicação para leigos)

1. **VPC (Virtual Private Cloud)**
	- Uma rede privada e isolada dentro da AWS, onde todos os recursos do projeto ficam protegidos e organizados.

2. **Subnet (Sub-rede)**
	- Uma parte da VPC onde a máquina virtual (servidor) é criada. Permite que o servidor tenha acesso à internet.

3. **Internet Gateway**
	- Um "portão" que conecta a rede privada (VPC) à internet, permitindo que o servidor seja acessado de fora.

4. **Route Table (Tabela de Rotas)**
	- Um conjunto de regras que diz para onde o tráfego de rede deve ir. Aqui, garante que o servidor pode acessar e ser acessado pela internet.

5. **Security Group**
	- Um "muro de proteção" que controla quem pode acessar o servidor. Neste projeto, está aberto para qualquer pessoa acessar qualquer porta (apenas para testes, não recomendado para produção).

6. **Key Pair (Par de Chaves SSH)**
	- Um par de arquivos (um público e um privado) que permite acessar o servidor de forma segura, sem precisar de senha.

7. **EC2 Instance (Instância EC2)**
	- A máquina virtual propriamente dita, onde o code-server (VS Code Web) é instalado automaticamente. Você pode acessar essa máquina pela internet e usar o VS Code direto do navegador.

8. **code-server**
	- Um servidor que roda o Visual Studio Code (VS Code) no navegador, permitindo programar remotamente como se estivesse usando o VS Code no seu computador.

Todos esses recursos são criados e configurados automaticamente pelo Terraform, bastando rodar os comandos indicados acima.
# Terraform AWS EC2 Example

Este projeto cria uma instância EC2 m7i-flex.large na AWS usando a AMI ami-0a174b8e659123575.

## Como usar

1. Configure suas credenciais AWS (via AWS CLI, variáveis de ambiente ou arquivo de credenciais).
2. Execute:

```bash
terraform init
terraform apply
```

3. Confirme a criação da instância quando solicitado.

## Variáveis
- `aws_region`: Região AWS (padrão: us-east-1)
- `ami_id`: ID da AMI (padrão: ami-0a174b8e659123575)
- `instance_type`: Tipo da instância (padrão: m7i-flex.large)


ssh -i ~/minha-chave-ec2.pem ubuntu@54.94.154.95