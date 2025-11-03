# ==== Galadriel, Celeborn, Oropher ====
apt install apache2-utils -y

htpasswd -bc /etc/nginx/.htpasswd noldor silvan

# [!] Bisa tambahin ke setiap server confignya [!]
# auth_basic "Restricted";
# auth_basic_user_file /etc/nginx/.htpasswd;

cat <<EOF >> /etc/nginx/sites-available/default
server {
    listen 8004;
    server_name galadriel.k55.com;
    root /var/www/html;
    index index.php index.html index.htm;

    auth_basic "Restricted";                   # <- [Tambahan]
    auth_basic_user_file /etc/nginx/.htpasswd; # <- [Tambahan]

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}

EOF

service nginx restart

curl -u noldor:silvan http://galadriel.k55.com:8004
curl -u noldor:silvan http://celeborn.k55.com:800
curl -u noldor:silvan http://oropher.k55.com:8006