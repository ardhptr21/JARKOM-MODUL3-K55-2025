# =================================================================
# === Aldarion (DHCP Server) Conf ===
# =================================================================
# Script ini akan menginstall dan mengkonfigurasi isc-dhcp-server.
# Pastikan Anda sudah menjalankan bagian Khamul terlebih dahulu untuk mendapatkan MAC Address-nya.

# 1. Instalasi
apt-get update
apt-get install -y isc-dhcp-server

# 2. Menentukan interface yang akan melayani DHCP
# Kita arahkan ke eth0 yang terhubung ke jaringan internal
echo 'INTERFACESv4="eth0"' > /etc/default/isc-dhcp-server

# 3. Konfigurasi DHCP Pools & Fixed Address
# GANTI "PASTE_MAC_ADDRESS_KHAMUL_DISINI" dengan MAC Address dari node Khamul
echo '
# Konfigurasi dasar
ddns-update-style none;
option domain-name "middle-earth.local";
option domain-name-servers 8.8.8.8, 8.8.4.4;
default-lease-time 600;
max-lease-time 7200;
authoritative;

# Subnet untuk Keluarga Manusia (range untuk Amandil)
subnet 10.91.1.0 netmask 255.255.255.0 {
  option routers 10.91.1.1;
  option broadcast-address 10.91.1.255;
  range 10.91.1.6 10.91.1.34;
  range 10.91.1.68 10.91.1.94;
}

# Subnet untuk Keluarga Peri (range untuk Gilgalad)
subnet 10.91.2.0 netmask 255.255.255.0 {
  option routers 10.91.2.1;
  option broadcast-address 10.91.2.255;
  range 10.91.2.35 10.91.2.67;
  range 10.91.2.96 10.91.2.121;
}

# Subnet untuk Khamul
subnet 10.91.3.0 netmask 255.255.255.0 {
  option routers 10.91.3.1;
  option broadcast-address 10.91.3.255;
}

# Alamat IP Tetap untuk Khamul
host Khamul {
  hardware ethernet PASTE_MAC_ADDRESS_KHAMUL_DISINI;
  fixed-address 10.91.3.95;
}
' > /etc/dhcp/dhcpd.conf

# 4. Restart service DHCP
service isc-dhcp-server restart


# =================================================================
# === Durin (DHCP Relay) Conf ===
# =================================================================
# Script ini akan menginstall dan mengkonfigurasi isc-dhcp-relay
# serta mengaktifkan IP forwarding agar paket bisa diteruskan antar jaringan.

# 1. Instalasi
apt-get update
apt-get install -y isc-dhcp-relay

# 2. Konfigurasi DHCP Relay
echo '
# Alamat IP dari DHCP Server (Aldarion)
SERVERS="10.91.4.2"

# Interfaces yang menghadap ke arah client
INTERFACES="eth1 eth2 eth3"
' > /etc/default/isc-dhcp-relay

# 3. Mengaktifkan IP Forwarding
# Menghapus tanda # pada baris net.ipv4.ip_forward=1
sed -i '/net.ipv4.ip_forward=1/s/^#//' /etc/sysctl.conf

# 4. Menerapkan perubahan sysctl dan restart service relay
sysctl -p
service isc-dhcp-relay restart


# =================================================================
# === Khamul (Client-Fixed-Address) Conf ===
# =================================================================
# Langkah pertama adalah mendapatkan MAC address, lalu mengubah
# konfigurasi network menjadi DHCP.

# 1. Dapatkan MAC Address (CATAT dan PASTE ke script Aldarion)
echo "--- MAC ADDRESS KHAMUL ---"
ip a | grep "link/ether"
echo "--------------------------"

# 2. Mengubah konfigurasi network menjadi DHCP
echo '
auto eth0
iface eth0 inet dhcp
' > /etc/network/interfaces

# 3. Restart interface network
ifdown eth0 && ifup eth0


# =================================================================
# === Amandil (Client-Dynamic-2) Conf ===
# =================================================================
# Script ini mengubah konfigurasi network menjadi DHCP.

# 1. Mengubah konfigurasi network menjadi DHCP
echo '
auto eth0
iface eth0 inet dhcp
' > /etc/network/interfaces

# 2. Restart interface network
ifdown eth0 && ifup eth0


# =================================================================
# === Gilgalad (Client-Dynamic-1) Conf ===
# =================================================================
# Script ini mengubah konfigurasi network menjadi DHCP.

# 1. Mengubah konfigurasi network menjadi DHCP
echo '
auto eth0
iface eth0 inet dhcp
' > /etc/network/interfaces

# 2. Restart interface network
ifdown eth0 && ifup eth0