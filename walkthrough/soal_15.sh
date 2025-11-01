# ==== Galadriel, Celeborn, Oropher ====

# [!] Bisa tambahin ke setiap server confignya [!]
# fastcgi_param HTTP_X_REAL_IP $remote_addr;

cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 8004;
    server_name galadriel.k55.com;
    root /var/www/html;
    index index.php index.html index.htm;

    auth_basic "Restricted";                  
    auth_basic_user_file /etc/nginx/.htpasswd;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
        fastcgi_param HTTP_X_REAL_IP \$remote_addr;               # <- [Tambahan]
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


cat <<EOF > /var/www/html/index.php
<?php
echo "Hostname: " . gethostname() . "\n";
echo "IP Address: " . \$_SERVER['HTTP_X_REAL_IP'] . "\n";
?>
EOF