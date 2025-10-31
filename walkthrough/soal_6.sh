# ==== ALDARION: Konfigurasi DHCP Lease Time ====

cat <<EOF > /etc/dhcp/dhcpd.conf
# Jadikan server ini sebagai satu-satunya sumber DHCP yang sah
authoritative;

# Opsi global: Arahkan DNS ke Erendis dan Amdir
option domain-name-servers 10.91.3.2, 10.91.3.3;

# Subnet untuk "Keluarga Manusia"
subnet 10.91.1.0 netmask 255.255.255.0 {
  range 10.91.1.6 10.91.1.34;
  range 10.91.1.68 10.91.1.94;
  option routers 10.91.1.1;
  option broadcast-address 10.91.1.255;
  default-lease-time 1800; # Setengah jam
  max-lease-time 3600;     # Satu jam
}

# Subnet untuk "Keluarga Peri"
subnet 10.91.2.0 netmask 255.255.255.0 {
  range 10.91.2.35 10.91.2.67;
  range 10.91.2.96 10.91.2.121;
  option routers 10.91.2.1;
  option broadcast-address 10.91.2.255;
  default-lease-time 600;  # Seperenam jam
  max-lease-time 3600;     # Satu jam
}

# Subnet untuk Khamul (tidak perlu lease time spesifik)
subnet 10.91.3.0 netmask 255.255.255.0 {
  option routers 10.91.3.1;
  option broadcast-address 10.91.3.255;
}

# Subnet untuk Aldarion sendiri
subnet 10.91.4.0 netmask 255.255.255.0 {
}

# Konfigurasi Fixed Address untuk Khamul
host Khamul {
  hardware ethernet 02:42:e8:63:34:00;
  fixed-address 10.91.3.95;
}
EOF

# Restart service DHCP untuk menerapkan perubahan
service isc-dhcp-server restart

# =================================================================
# Validasi di Klien (Amandil): Untuk memaksa Amandil meminta lease yang benar-benar baru (lengkap dengan lease time yang baru), ikuti langkah ini:

# Restart penuh node Amandil dari antarmuka GNS3 (Stop, lalu Start).

# Setelah Amandil menyala, buka konsolnya dan jalankan ip a. 