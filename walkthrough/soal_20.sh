# ==== Pharazon ====

cat <<EOF > /etc/nginx/sites-available/default
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=pharazon_cache:100m inactive=60m use_temp_path=off;
proxy_cache_key "\$scheme\$request_method\$host\$request_uri";

limit_req_zone \$binary_remote_addr zone=limit_zone:10m rate=10r/s;

upstream Kesatria_Lorien {
    server galadriel.k55.com:8004;
    server celeborn.k55.com:8005;
    server oropher.k55.com:8006;
}

server {
    listen 80;
    server_name pharazon.k55.com;

    proxy_cache pharazon_cache;
    proxy_cache_valid 200 302 2m;
    proxy_cache_valid 404 1m;
    

    location / {
        limit_req zone=limit_zone burst=20 nodelay;

        proxy_cache pharazon_cache;
        proxy_cache_valid 200 302 2m;
        proxy_cache_valid 404 1m;
        add_header X-Cache-Status \$upstream_cache_status;
        
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

service nginx restart