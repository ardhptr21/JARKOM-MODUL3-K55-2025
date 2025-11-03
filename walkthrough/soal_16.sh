# ==== Pharazon ====
apt update
apt install nginx -y

cat <<EOF > /etc/nginx/sites-available/default
upstream Kesatria_Lorien {
    server 10.91.2.2:8004;
    server 10.91.2.3:8005;
    server 10.91.2.4:8006;
}

server {
    listen 80;
    server_name pharazon.k55.com;

    access_log /var/log/nginx/pharazon_access.log;
    error_log /var/log/nginx/pharazon_error.log;

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

EOF