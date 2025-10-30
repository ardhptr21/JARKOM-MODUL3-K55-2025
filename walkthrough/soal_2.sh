# === aldarion ===

# 1. Install paket DHCP server
apt-get update
apt-get install -y isc-dhcp-server

# 2. Tentukan interface yang akan melayani DHCP (eth0)
# Kita memberitahu service DHCP untuk "mendengarkan" permintaan di eth0
cat <<EOF > /etc/default/isc-dhcp-server
INTERFACESv4="eth0"
EOF

# 3. Konfigurasi utama DHCP server
# Di sini kita mendefinisikan semua aturan pembagian IP
cat <<EOF > /etc/dhcp/dhcpd.conf
# Opsi default untuk semua subnet
option domain-name "prakjarkom.com";
option domain-name-servers 8.8.8.8, 8.8.4.4;
default-lease-time 600;
max-lease-time 7200;

# Konfigurasi agar server ini menjadi satu-satunya DHCP server yang sah di jaringan
authoritative;

# Subnet untuk "Keluarga Manusia" (contoh: Amandil, Elros)
subnet 10.91.1.0 netmask 255.255.255.0 {
  # Rentang IP yang akan dibagikan
  range 10.91.1.6 10.91.1.34;
  range 10.91.1.68 10.91.1.94;
  option routers 10.91.1.1;
  option broadcast-address 10.91.1.255;
}

# Subnet untuk "Keluarga Peri" (contoh: Gilgalad)
subnet 10.91.2.0 netmask 255.255.255.0 {
  range 10.91.2.35 10.91.2.67;
  range 10.91.2.96 10.91.2.121;
  option routers 10.91.2.1;
  option broadcast-address 10.91.2.255;
}

# Subnet untuk Khamul
subnet 10.91.3.0 netmask 255.255.255.0 {
  option routers 10.91.3.1;
  option broadcast-address 10.91.3.255;
}

host Khamul {
  hardware ethernet 02:42:7d:47:03:00; # <-- GANTI DENGAN MAC ADDRESS Node KHAMUL ANDA (02:42:7d:47:03:00)
  fixed-address 10.91.3.95;
}
EOF

# 4. Restart service DHCP agar konfigurasi baru diterapkan
service isc-dhcp-server restart

#==================================================================
# ==== Durin: Konfigurasi DHCP Relay ====

# 1. Install paket yang dibutuhkan untuk menjadi relay
apt-get update
apt-get install -y isc-dhcp-relay

# 2. Buat file konfigurasi untuk service relay
cat <<EOF > /etc/default/isc-dhcp-relay
# Alamat IP dari DHCP Server utama (Aldarion)
SERVERS="10.91.4.2"

# Interfaces yang "didengarkan" oleh relay
# eth1, eth2, eth3 (ke klien) DAN eth4 (ke server)
INTERFACES="eth1 eth2 eth3 eth4"
EOF

# 3. Aktifkan IP Forwarding agar Durin bisa meneruskan paket antar subnet
# (Mungkin sudah Anda lakukan saat setup NAT, tapi ini untuk memastikan)
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# 4. Restart service relay agar konfigurasi baru diterapkan
service isc-dhcp-relay restart

# Verifikasi status service relay
ps aux | grep dhcpd

#==================================================================
# === khamul, Amandil, dan Gilgalad ===

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet dhcp
EOF