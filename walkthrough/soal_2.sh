# ==== SCRIPT UNTUK ALDARION ====

# 1. Install paket DHCP Server
apt-get update
apt-get install -y isc-dhcp-server

# 2. Tentukan interface yang akan melayani DHCP
echo 'INTERFACESv4="eth0"' > /etc/default/isc-dhcp-server

# 3. Buat file konfigurasi utama DHCP
cat <<EOF > /etc/dhcp/dhcpd.conf
# Jadikan server ini sebagai satu-satunya sumber DHCP yang sah
authoritative;

# Subnet untuk "Keluarga Manusia"
subnet 10.91.1.0 netmask 255.255.255.0 {
  range 10.91.1.6 10.91.1.34;
  range 10.91.1.68 10.91.1.94;
  option routers 10.91.1.1;
  option broadcast-address 10.91.1.255;
}

# Subnet untuk "Keluarga Peri"
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

# Deklarasi subnet tempat Aldarion berada (wajib agar service bisa berjalan)
subnet 10.91.4.0 netmask 255.255.255.0 {
}

# Konfigurasi IP tetap (Fixed Address) untuk Khamul
host Khamul {
  hardware ethernet 02:42:7d:47:03:00;
  fixed-address 10.91.3.95;
}
EOF

# 4. Restart service DHCP untuk menerapkan konfigurasi
service isc-dhcp-server restart

#==================================================================
# ==== Durin: Konfigurasi DHCP Relay ====

# 1. Install paket DHCP Relay
apt-get update
apt-get install -y isc-dhcp-relay

# 2. Konfigurasi service relay
cat <<EOF > /etc/default/isc-dhcp-relay
# Alamat IP DHCP Server (Aldarion)
SERVERS="10.91.4.2"

# Interface yang mendengarkan permintaan klien DAN menuju ke server
INTERFACES="eth1 eth2 eth3 eth4"
EOF

# 3. Aktifkan IP Forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# 4. Restart service relay
service isc-dhcp-relay restart

# Verifikasi status service relay
ps aux | grep dhcpd

#==================================================================
# === khamul, Amandil, dan Gilgalad ===

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet dhcp
EOF

#=============== validasi ============================
# bisa "install DHCP client" dan "dhclient -v eth0" pada khamul, Amandil, dan Gilgalad
ip a
dhclient -v eth0