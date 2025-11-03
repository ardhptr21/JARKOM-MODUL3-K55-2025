# ==== ELROS: Konfigurasi Reverse Proxy (Load Balancer) ====

# 1. Install Nginx
apt-get update
apt-get install -y nginx

# 2. Buat file konfigurasi Nginx untuk reverse proxy
cat <<EOF > /etc/nginx/sites-available/elros.K55.com
# Definisikan grup server backend (para worker)
upstream kesatria_numenor {
    # Round Robin adalah algoritma default, jadi tidak perlu kata kunci
    server 10.91.1.2:8001;  # Elendil
    server 10.91.1.3:8002;  # Isildur
    server 10.91.1.4:8003;  # Anarion
}

server {
    listen 80;
    server_name elros.K55.com;

    access_log /var/log/nginx/elros_access.log;
    error_log /var/log/nginx/elros_error.log;

    location / {
        # Teruskan semua permintaan ke grup 'kesatria_numenor'
        proxy_pass http://kesatria_numenor;
        
        # Teruskan header asli dari klien
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# 3. Aktifkan situs baru
ln -s /etc/nginx/sites-available/elros.K55.com /etc/nginx/sites-enabled/

# 4. Hapus situs default agar tidak bentrok
rm /etc/nginx/sites-enabled/default

# 5. Restart Nginx untuk menerapkan perubahan
service nginx restart




# ==== perbaikan elendil kalau pas dicek access.lognya pada elendil kode 500 ====
# ==== ELENDIL: Perbaikan Ulang Setup Worker ====

# 1. Masuk ke direktori aplikasi
cd /var/www/laravel-simple-rest-api

# 2. Jalankan 'composer update' untuk memastikan dependensi ada
echo "Menjalankan composer update... Ini mungkin perlu waktu..."
composer update

# 3. Pastikan file .env ada
if [ ! -f ".env" ]; then
    cp .env.example .env
fi

# 4. Generate ulang key aplikasi
php artisan key:generate

# 5. Setel ulang izin folder
chown -R www-data:www-data /var/www/laravel-simple-rest-api/storage
chown -R www-data:www-data /var/www/laravel-simple-rest-api/bootstrap/cache

# 6. Restart semua service
service php8.4-fpm restart
service nginx restart

echo "Perbaikan Elendil selesai."