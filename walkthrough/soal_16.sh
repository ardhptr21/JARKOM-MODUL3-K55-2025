# ==== Pharazon ====
apt update
apt install nginx -y

cat <<EOF > /etc/nginx/sites-available/default
upstream Kesatria_Lorien {
    server galadriel.k55.com:8004;
    server celeborn.k55.com:8005;
    server oropher.k55.com:8006;
}

server {
    listen 80;
    server_name pharazon.k55.com;

    location / {
        proxy_pass http://Kesatria_Lorien;

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        proxy_pass_header Authorization;
        proxy_set_header Authorization \$http_authorization;
    }
}

server {
  listen 8004 default_server;
  server_name _;
  return 301 http://pharazon.k55.com\$request_uri;
}

EOF