# ==== Galadriel, Celeborn, Oropher ====
# [PORT]
# Galadriel: 8004
# Celeborn: 8005
# Oropher: 8006

# [SERVER NAME]
# Galadriel: galadriel.k55.com
# Celeborn: celeborn.k55.com
# Oropher: oropher.k55.com

cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 8004;
    server_name galadriel.k55.com;
    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}

server {
  listen 8004 default_server;
  server_name _;
  return 444;
}

EOF

service php8.4-fpm start
service nginx restart


curl http://galadriel.k55.com:8004
curl http://celeborn.k55.com:8005
curl http://oropher.k55.com:8006