# ==== ELENDIL: Setup Worker Laravel ====
# --- 1. Instalasi Paket yang Dibutuhkan ---
apt-get update

# Install paket prasyarat untuk menambah repositori PHP
apt-get install -y lsb-release apt-transport-https ca-certificates wget

# Tambahkan GPG key dan repositori Sury untuk PHP 8.4
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
apt-get update

# Install semua perkakas: PHP 8.4, ekstensinya, Nginx, Git, dan Composer
# Kita tambahkan php8.4-mysql karena akan dibutuhkan untuk Soal 8
apt-get install -y php8.4-fpm php8.4-mbstring php8.4-xml php8.4-mysql php8.4-cli php8.4-common php8.4-intl nginx git composer

# --- 2. Unduh dan Siapkan Aplikasi Laravel ---
# Pindah ke direktori web server
cd /var/www

# Unduh kode aplikasi dari GitHub (Resource-laravel)
git clone https://github.com/elshiraphine/laravel-simple-rest-api.git

# Masuk ke direktori proyek
cd laravel-simple-rest-api

# Install semua dependensi PHP dengan Composer
composer install

# Buat file environment dari contoh yang ada
cp .env.example .env

# Buat kunci enkripsi aplikasi
php artisan key:generate

# --- 3. Konfigurasi Nginx ---
# Buat file konfigurasi server block untuk Laravel
cat <<EOF > /etc/nginx/sites-available/laravel
server {
    # !!! PENTING: UBAH PORT DI BAWAH INI SESUAI NODE !!!
    # Elendil: 8001
    # Isildur: 8002
    # Anarion: 8003
    listen 8001;

    root /var/www/laravel-simple-rest-api/public;
    index index.php index.html index.htm;
    server_name _;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        # Pastikan ini menunjuk ke versi PHP yang benar
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# --- 4. Finalisasi dan Jalankan Layanan ---
# Aktifkan situs Laravel dengan membuat symbolic link
ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/

# Hapus konfigurasi default agar tidak bentrok
rm /etc/nginx/sites-enabled/default

# Berikan izin akses folder 'storage' Laravel kepada web server
chown -R www-data:www-data /var/www/laravel-simple-rest-api/storage

# Mulai service PHP-FPM dan restart Nginx
service php8.4-fpm start
service nginx restart

# ==== PERBAIKAN: Worker Laravel (Elendil, Isildur, Anarion) ====

# 1. Masuk ke direktori aplikasi
cd /var/www/laravel-simple-rest-api

# 2. Jalankan 'composer update' untuk mendapatkan paket yang kompatibel
# Ini mungkin memakan waktu 1-2 menit
composer update

# 3. Sekarang jalankan 'key:generate' (seharusnya berhasil)
php artisan key:generate






# ==== ISILDUR: Setup Worker Laravel ====
# --- 1. Instalasi Paket yang Dibutuhkan ---
apt-get update

# Install paket prasyarat untuk menambah repositori PHP
apt-get install -y lsb-release apt-transport-https ca-certificates wget

# Tambahkan GPG key dan repositori Sury untuk PHP 8.4
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
apt-get update

# Install semua perkakas: PHP 8.4, ekstensinya, Nginx, Git, dan Composer
# Kita tambahkan php8.4-mysql karena akan dibutuhkan untuk Soal 8
apt-get install -y php8.4-fpm php8.4-mbstring php8.4-xml php8.4-mysql php8.4-cli php8.4-common php8.4-intl nginx git composer

# --- 2. Unduh dan Siapkan Aplikasi Laravel ---
# Pindah ke direktori web server
cd /var/www

# Unduh kode aplikasi dari GitHub (Resource-laravel)
git clone https://github.com/elshiraphine/laravel-simple-rest-api.git

# Masuk ke direktori proyek
cd laravel-simple-rest-api

# Install semua dependensi PHP dengan Composer
composer install

# Buat file environment dari contoh yang ada
cp .env.example .env

# Buat kunci enkripsi aplikasi
php artisan key:generate

# --- 3. Konfigurasi Nginx ---
# Buat file konfigurasi server block untuk Laravel
cat <<EOF > /etc/nginx/sites-available/laravel
server {
    # !!! PENTING: UBAH PORT DI BAWAH INI SESUAI NODE !!!
    # Elendil: 8001
    # Isildur: 8002
    # Anarion: 8003
    listen 8002;

    root /var/www/laravel-simple-rest-api/public;
    index index.php index.html index.htm;
    server_name _;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        # Pastikan ini menunjuk ke versi PHP yang benar
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# --- 4. Finalisasi dan Jalankan Layanan ---
# Aktifkan situs Laravel dengan membuat symbolic link
ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/

# Hapus konfigurasi default agar tidak bentrok
rm /etc/nginx/sites-enabled/default

# Berikan izin akses folder 'storage' Laravel kepada web server
chown -R www-data:www-data /var/www/laravel-simple-rest-api/storage

# Mulai service PHP-FPM dan restart Nginx
service php8.4-fpm start
service nginx restart

# ==== PERBAIKAN: Worker Laravel (Elendil, Isildur, Anarion) ====

# 1. Masuk ke direktori aplikasi
cd /var/www/laravel-simple-rest-api

# 2. Jalankan 'composer update' untuk mendapatkan paket yang kompatibel
# Ini mungkin memakan waktu 1-2 menit
composer update

# 3. Sekarang jalankan 'key:generate' (seharusnya berhasil)
php artisan key:generate



# ==== ANARION: Setup Worker Laravel ====
# --- 1. Instalasi Paket yang Dibutuhkan ---
apt-get update

# Install paket prasyarat untuk menambah repositori PHP
apt-get install -y lsb-release apt-transport-https ca-certificates wget

# Tambahkan GPG key dan repositori Sury untuk PHP 8.4
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
apt-get update

# Install semua perkakas: PHP 8.4, ekstensinya, Nginx, Git, dan Composer
# Kita tambahkan php8.4-mysql karena akan dibutuhkan untuk Soal 8
apt-get install -y php8.4-fpm php8.4-mbstring php8.4-xml php8.4-mysql php8.4-cli php8.4-common php8.4-intl nginx git composer

# --- 2. Unduh dan Siapkan Aplikasi Laravel ---
# Pindah ke direktori web server
cd /var/www

# Unduh kode aplikasi dari GitHub (Resource-laravel)
git clone https://github.com/elshiraphine/laravel-simple-rest-api.git

# Masuk ke direktori proyek
cd laravel-simple-rest-api

# Install semua dependensi PHP dengan Composer
composer install

# Buat file environment dari contoh yang ada
cp .env.example .env

# Buat kunci enkripsi aplikasi
php artisan key:generate

# --- 3. Konfigurasi Nginx ---
# Buat file konfigurasi server block untuk Laravel
cat <<EOF > /etc/nginx/sites-available/laravel
server {
    # !!! PENTING: UBAH PORT DI BAWAH INI SESUAI NODE !!!
    # Elendil: 8001
    # Isildur: 8002
    # Anarion: 8003
    listen 8003;

    root /var/www/laravel-simple-rest-api/public;
    index index.php index.html index.htm;
    server_name _;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        # Pastikan ini menunjuk ke versi PHP yang benar
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# --- 4. Finalisasi dan Jalankan Layanan ---
# Aktifkan situs Laravel dengan membuat symbolic link
ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/

# Hapus konfigurasi default agar tidak bentrok
rm /etc/nginx/sites-enabled/default

# Berikan izin akses folder 'storage' Laravel kepada web server
chown -R www-data:www-data /var/www/laravel-simple-rest-api/storage

# Mulai service PHP-FPM dan restart Nginx
service php8.4-fpm start
service nginx restart


# ==== PERBAIKAN: Worker Laravel (Elendil, Isildur, Anarion) ====

# 1. Masuk ke direktori aplikasi
cd /var/www/laravel-simple-rest-api

# 2. Jalankan 'composer update' untuk mendapatkan paket yang kompatibel
# Ini mungkin memakan waktu 1-2 menit
composer update

# 3. Sekarang jalankan 'key:generate' (seharusnya berhasil)
php artisan key:generate