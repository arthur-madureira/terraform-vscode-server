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
cat <<EOF > /etc/nginx/sites-available/code-server
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
EOF
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
