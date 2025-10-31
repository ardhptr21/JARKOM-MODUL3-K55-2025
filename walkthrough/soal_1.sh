# === Durin (Router) conf ===
# Konfigurasi interfaces untuk Durin
cat <<EOF > /etc/network/interfaces
# Interface untuk koneksi ke Internet (NAT)
auto eth0
iface eth0 inet dhcp

# Interface ke jaringan Numenor (Elendil, Isildur, dkk)
auto eth1
iface eth1 inet static
  address 10.91.1.1
  netmask 255.255.255.0

# Interface ke jaringan Peri (Galadriel, Celeborn, dkk)
auto eth2
iface eth2 inet static
  address 10.91.2.1
  netmask 255.255.255.0

# Interface ke jaringan Erendis & Khamul
auto eth3
iface eth3 inet static
  address 10.91.3.1
  netmask 255.255.255.0

# Interface ke jaringan Server (Aldarion, Palantir, dkk)
auto eth4
iface eth4 inet static
  address 10.91.4.1
  netmask 255.255.255.0

# Interface ke Minastir
auto eth5
iface eth5 inet static
  address 10.91.5.1
  netmask 255.255.255.0
EOF

cat <<EOF > /root/.bashrc
apt update
apt install iptables -y
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.91.0.0/16
EOF

### === Node dengan IP Statis ===
# Untuk setiap node berikut, kita akan memberikan IP statis, gateway, dan mengatur resolv.conf secara manual agar bisa terhubung ke internet untuk instalasi awal.

# Elendil
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.1.2
  netmask 255.255.255.0
  gateway 10.91.1.1
EOF

# Isildur
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.1.3
  netmask 255.255.255.0
  gateway 10.91.1.1
EOF

# Anarion
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.1.4
  netmask 255.255.255.0
  gateway 10.91.1.1
EOF

# Miriel
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.1.5
  netmask 255.255.255.0
  gateway 10.91.1.1
EOF

# elros
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.1.6
  netmask 255.255.255.0
  gateway 10.91.1.1
EOF

# Galadriel
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.2.2
  netmask 255.255.255.0
  gateway 10.91.2.1
EOF

# Celeborn
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.2.3
  netmask 255.255.255.0
  gateway 10.91.2.1
EOF

# Oropher
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.2.4
  netmask 255.255.255.0
  gateway 10.91.2.1
EOF

# Celebrimbor
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.2.5
  netmask 255.255.255.0
  gateway 10.91.2.1
EOF

# Pharazon
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.2.6
  netmask 255.255.255.0
  gateway 10.91.2.1
EOF

# Erendis
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.3.2
  netmask 255.255.255.0
  gateway 10.91.3.1
EOF

# Amdir
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.3.3
  netmask 255.255.255.0
  gateway 10.91.3.1
EOF

# Aldarion
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.4.2
  netmask 255.255.255.0
  gateway 10.91.4.1
EOF

# Palantir
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.4.3
  netmask 255.255.255.0
  gateway 10.91.4.1
EOF

# Narvi
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.4.4
  netmask 255.255.255.0
  gateway 10.91.4.1
EOF

# Minastir
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.5.2
  netmask 255.255.255.0
  gateway 10.91.5.1
EOF

# Jalankan di SEMUA node kecuali Durin
cat <<EOF > /root/.bashrc
# Mengatur DNS resolver agar menunjuk ke nameserver GNS3 untuk akses internet
echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF

### === Node dengan IP Statis sementara ===
# ini akan memberi mereka alamat IP, gateway, dan koneksi internet untuk sementara.

#### === Gilgalad conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.2.7
  netmask 255.255.255.0
  gateway 10.91.2.1
EOF

cat <<EOF > /root/.bashrc
echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF

#### === Amandil conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.1.7
  netmask 255.255.255.0
  gateway 10.91.1.1
EOF

cat <<EOF > /root/.bashrc
echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF

#### === Khamul conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.3.4
  netmask 255.255.255.0
  gateway 10.91.3.1
EOF

cat <<EOF > /root/.bashrc
echo "nameserver 192.168.122.1" > /etc/resolv.conf
ping google.com -c 2
EOF
