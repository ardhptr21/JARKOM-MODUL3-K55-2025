# ==== PALANTIR: Script Final Konfigurasi MariaDB ====

# 1. Install paket
apt-get update
apt-get install -y mariadb-server net-tools

# 2. Mulai service
service mariadb start

# 3. Buat database dan user
mariadb -e "
DROP USER IF EXISTS 'k55_user'@'%';
CREATE USER 'k55_user'@'%' IDENTIFIED BY 'passwordk55';
CREATE DATABASE IF NOT EXISTS db_k55;
GRANT ALL PRIVILEGES ON db_k55.* TO 'k55_user'@'%';
FLUSH PRIVILEGES;
"

# 4. Hentikan service untuk mengedit file
service mariadb stop

# 5. Tentukan file konfigurasi
CONFIG_FILE="/etc/mysql/mariadb.conf.d/50-server.cnf"
if [ ! -f "$CONFIG_FILE" ]; then
    CONFIG_FILE="/etc/mysql/my.cnf"
fi

# 6. Perbaikan: Izinkan koneksi eksternal (mengomentari bind-address)
sed -i "s/bind-address\s*=\s*127.0.0.1/#bind-address = 127.0.0.1/" "$CONFIG_FILE"
sed -i "/skip-networking/d" "$CONFIG_FILE"

# 7. Mulai service lagi
service mariadb start

# 8. Verifikasi (opsional)
echo "--- Verifikasi Port MariaDB (harus 0.0.0.0): ---"
netstat -tulpn | grep 3306





# ==== WORKER (Elendil, Isildur, Anarion): Konfigurasi .env ====
ENV_FILE="/var/www/laravel-simple-rest-api/.env"

sed -i "s/DB_HOST=127.0.0.1/DB_HOST=10.91.4.3/" $ENV_FILE
sed -i "s/DB_DATABASE=laravel/DB_DATABASE=db_k55/" $ENV_FILE
sed -i "s/DB_USERNAME=root/DB_USERNAME=k55_user/" $ENV_FILE
sed -i "s/DB_PASSWORD=/DB_PASSWORD=passwordk55/" $ENV_FILE

echo "File .env telah dikonfigurasi."



# ==== ELENDIL: Migrasi dan Seeding Database ====

# ==== ELENDIL: Migrasi dan Seeding Database ====
cd /var/www/laravel-simple-rest-api
php artisan migrate:fresh
php artisan db:seed --class=AiringsTableSeeder
echo "Migrasi dan seeding selesai."


# ==== ELENDIL: Konfigurasi Nginx (Domain Only) ====
sed -i "s/server_name _;/server_name elendil.K55.com;/" /etc/nginx/sites-available/laravel
service nginx restart


# ==== ISILDUR: Konfigurasi Nginx (Domain Only) ====
sed -i "s/server_name _;/server_name isildur.K55.com;/" /etc/nginx/sites-available/laravel
service nginx restart

# ==== ANARION: Konfigurasi Nginx (Domain Only) ====
sed -i "s/server_name _;/server_name anarion.K55.com;/" /etc/nginx/sites-available/laravel
service nginx restart














# === tadi sempat ada perbaikan part 1 ===
# ==== PALANTIR: Perbaikan Konfigurasi MariaDB ====

# 1. Pastikan service berjalan (seharusnya sudah)
service mariadb start

# 2. Hapus user lama (jika ada) dan buat user baru dengan benar
# Kita jalankan ini di dalam satu blok 'mariadb -e' untuk memastikan
mariadb -e "
DROP USER IF EXISTS 'k55_user'@'%';
CREATE USER 'k55_user'@'%' IDENTIFIED BY 'passwordk55';
CREATE DATABASE IF NOT EXISTS db_k55;
GRANT ALL PRIVILEGES ON db_k55.* TO 'k55_user'@'%';
FLUSH PRIVILEGES;
"

# 3. Konfigurasi ulang bind-address dengan cara yang lebih pasti
# Kita akan mencari baris 'bind-address' dan mengubahnya menjadi '0.0.0.0'
# Jika tidak ada, kita tambahkan di bawah [mysqld]
# Ini sedikit rumit, tapi lebih andal:
if grep -q "bind-address" /etc/mysql/my.cnf; then
    sed -i "s/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
else
    sed -i "/\[mysqld\]/a bind-address = 0.0.0.0" /etc/mysql/my.cnf
fi
# Hapus juga 'skip-networking' jika ada
sed -i "/skip-networking/d" /etc/mysql/my.cnf


# 4. Restart MariaDB untuk menerapkan perubahan
service mariadb restart

echo "Konfigurasi Palantir telah diperbaiki."




# ==== ELENDIL: Coba Lagi Migrasi ====

# Masuk ke direktori aplikasi
cd /var/www/laravel-simple-rest-api

# Jalankan migrasi (membuat tabel)
php artisan migrate:fresh

# Jalankan seeding (mengisi data)
php artisan db:seed --class=AiringsTableSeeder

echo "Migrasi dan seeding selesai."



# === tadi sempat ada perbaikan part 2 ===
# ==== PALANTIR: Perbaikan Final Konfigurasi MariaDB ====

# 1. Install 'net-tools' untuk debugging
apt-get update
apt-get install -y net-tools

# 2. Cek port yang sedang didengarkan
echo "--- Keadaan Sebelum Perbaikan: ---"
netstat -tulpn | grep 3306
# (Output di sini kemungkinan besar akan menunjukkan '127.0.0.1:3306')

# 3. Hentikan service dulu
service mariadb stop

# 4. Cari file konfigurasi yang benar (biasanya 50-server.cnf)
CONFIG_FILE="/etc/mysql/mariadb.conf.d/50-server.cnf"

# Jika file itu tidak ada, gunakan my.cnf
if [ ! -f "$CONFIG_FILE" ]; then
    CONFIG_FILE="/etc/mysql/my.cnf"
fi

echo "Mengedit file: $CONFIG_FILE"

# 5. Nonaktifkan 'bind-address = 127.0.0.1' (mengubahnya menjadi komentar)
sed -i "s/bind-address\s*=\s*127.0.0.1/#bind-address = 127.0.0.1/" "$CONFIG_FILE"

# 6. Pastikan 'skip-networking' tidak aktif (jika ada)
sed -i "s/skip-networking\s*=\s*1/skip-networking = 0/" "$CONFIG_FILE"

# 7. Mulai service lagi
service mariadb start

# 8. Cek port lagi setelah perbaikan
echo "--- Keadaan Setelah Perbaikan: ---"
netstat -tulpn | grep 3306
# (Output di sini SEKARANG harus menunjukkan '0.0.0.0:3306' atau ':::3306')



# ==== ELENDIL: Coba Lagi Migrasi ====

# Masuk ke direktori aplikasi
cd /var/www/laravel-simple-rest-api

# Jalankan migrasi (membuat tabel)
# 'migrate:fresh' akan menghapus semua tabel dan membuatnya ulang
php artisan migrate:fresh

# Jalankan seeding (mengisi data)
php artisan db:seed --class=AiringsTableSeeder

echo "Migrasi dan seeding selesai."