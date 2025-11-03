# ==== MIRIEL: Installasi Apache Benchmark & Htop ====
apt-get update
apt-get install -y apache2-utils htop

# ==== WORKERS: Installasi Htop ====
# (Jalankan di ketiga node Elendil, Isildur, Anarion)
apt-get update
apt-get install -y htop


# ==== MIRIEL: Menjalankan Tes ====

# --- TES 1: SERANGAN AWAL ---
# (Pastikan 3 worker Anda sedang menjalankan 'htop')
echo "--- MENJALANKAN TES 1: 100 REQUESTS, 10 BERSAMAAN ---"
ab -n 100 -c 10 http://elros.K55.com/api/airing/
echo "--- TES 1 SELESAI ---"


# --- TES 2: SERANGAN PENUH (ROUND ROBIN) ---
echo "--- MENJALANKAN TES 2: 2000 REQUESTS, 100 BERSAMAAN ---"
ab -n 2000 -c 100 http://elros.K55.com/api/airing/
echo "--- TES 2 SELESAI, CATAT JUMLAH 'FAILED REQUESTS' ---"


# ==== ELROS: Terapkan Strategi Weight ====

cat <<EOF > /etc/nginx/sites-available/elros.K55.com
upstream kesatria_numenor {
    # Beri Elendil beban 3x lipat, Isildur 2x lipat
    server 10.91.1.2:8001 weight=3;
    server 10.91.1.3:8002 weight=2;
    server 10.91.1.4:8003; # weight=1 (default)
}

server {
    listen 80;
    server_name elros.K55.com;

    access_log /var/log/nginx/elros_access.log;
    error_log /var/log/nginx/elros_error.log;

    location / {
        proxy_pass http://kesatria_numenor;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Restart Nginx
service nginx restart


# ==== MIRIEL: Menjalankan Tes 3 (Uji Coba Weight) ====

# --- TES 3: SERANGAN PENUH (DENGAN WEIGHT) ---
echo "--- MENJALANKAN TES 3: 2000 REQUESTS, 100 BERSAMAAN (DENGAN WEIGHT) ---"
ab -n 2000 -c 100 http://elros.K55.com/api/airing/
echo "--- TES 3 SELESAI, BANDINGKAN 'FAILED REQUESTS' DENGAN TES 2 ---"