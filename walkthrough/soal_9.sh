# ==== MIRIEL (Klien): Validasi Soal 9 ====

# 1. Pastikan tools 'lynx' dan 'curl' terinstall
apt-get update
apt-get install -y lynx curl

# 2. Pastikan DNS sudah benar (menunjuk ke Erendis/Amdir)
# (Ini seharusnya sudah diatur di Soal 4/5)
echo -e "nameserver 10.91.3.2\nnameserver 10.91.3.3" > /etc/resolv.conf

# --- Validasi Halaman Utama (lynx) ---
echo "--- Menguji Halaman Utama Elendil (8001) ---"
lynx -dump http://elendil.K55.com:8001

echo "--- Menguji Halaman Utama Isildur (8002) ---"
lynx -dump http://isildur.K55.com:8002

echo "--- Menguji Halaman Utama Anarion (8003) ---"
lynx -dump http://anarion.K55.com:8003

# --- Validasi Koneksi Database (curl) ---
echo "--- Menguji API Elendil (koneksi DB) ---"
curl http://elendil.K55.com:8001/api/airing

echo "--- Menguji API Isildur (koneksi DB) ---"
curl http://isildur.K55.com:8002/api/airing

echo "--- Menguji API Anarion (koneksi DB) ---"
curl http://anarion.K55.com:8003/api/airing