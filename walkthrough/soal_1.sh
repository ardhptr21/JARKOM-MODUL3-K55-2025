# === Durin (Router) conf ===
# Konfigurasi interfaces untuk Durin
cat <<EOF > /etc/network/interfaces
# Dapatkan IP dari NAT untuk koneksi internet
auto eth0
iface eth0 inet dhcp

# Gateway untuk jaringan Numenor (Elendil, Isildur, dll)
auto eth1
iface eth1 inet static
  address 10.91.1.1
  netmask 255.255.255.0

# Gateway untuk jaringan Peri (Galadriel, Celeborn, dll)
auto eth2
iface eth2 inet static
  address 10.91.2.1
  netmask 255.255.255.0

# Gateway untuk jaringan Khamul & Elros
auto eth3
iface eth3 inet static
  address 10.91.3.1
  netmask 255.255.255.0

# Gateway untuk jaringan Database & DHCP Server
auto eth4
iface eth4 inet static
  address 10.91.4.1
  netmask 255.255.255.0

# Gateway untuk jaringan Minastir & Pharazon
auto eth5
iface eth5 inet static
  address 10.91.5.1
  netmask 255.255.255.0
EOF

# Aktifkan IP Forwarding agar bisa merutekan paket
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

cat <<EOF > /root/.bashrc
apt update
apt install iptables -y
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.91.0.0/16
EOF


### === Node dengan IP Statis ===
# Untuk setiap node berikut, kita akan memberikan IP statis, gateway, dan mengatur resolv.conf secara manual agar bisa terhubung ke internet untuk instalasi awal.

#### === Elendil conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.1.2
  netmask 255.255.255.0
  gateway 10.91.1.1
EOF
echo "nameserver 192.168.122.1" > /etc/resolv.conf

#### === Isildur conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.1.3
  netmask 255.255.255.0
  gateway 10.91.1.1
EOF
echo "nameserver 192.168.122.1" > /etc/resolv.conf

#### === Anarion conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.1.4
  netmask 255.255.255.0
  gateway 10.91.1.1
EOF
echo "nameserver 192.168.122.1" > /etc/resolv.conf

#### === Miriel conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.1.5
  netmask 255.255.255.0
  gateway 10.91.1.1
EOF
echo "nameserver 192.168.122.1" > /etc/resolv.conf

#### === Elros conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.1.6
  netmask 255.255.255.0
  gateway 10.91.3.1
EOF
echo "nameserver 192.168.122.1" > /etc/resolv.conf

#### === Erendis (DNS Master) conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.3.2
  netmask 255.255.255.0
  gateway 10.91.3.1
EOF
echo "nameserver 192.168.122.1" > /etc/resolv.conf

#### === Amdir (DNS Slave) conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.3.3
  netmask 255.255.255.0
  gateway 10.91.3.1
EOF
echo "nameserver 192.168.122.1" > /etc/resolv.conf

#### === Aldarion (DHCP Server) conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.4.2
  netmask 255.255.255.0
  gateway 10.91.4.1
EOF
echo "nameserver 192.168.122.1" > /etc/resolv.conf

#### === Palantir (DB Master) conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.4.3
  netmask 255.255.255.0
  gateway 10.91.4.1
EOF
echo "nameserver 192.168.122.1" > /etc/resolv.conf

#### === Narvi (DB Slave) conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.4.4
  netmask 255.255.255.0
  gateway 10.91.4.1
EOF
echo "nameserver 192.168.122.1" > /etc/resolv.conf

#### === Minastir conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.5.2
  netmask 255.255.255.0
  gateway 10.91.5.1
EOF
echo "nameserver 192.168.122.1" > /etc/resolv.conf

#### === Galadriel conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.2.2
  netmask 255.255.255.0
  gateway 10.91.2.1
EOF
echo "nameserver 192.168.122.1" > /etc/resolv.conf

#### === Celeborn conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.2.3
  netmask 255.255.255.0
  gateway 10.91.2.1
EOF
echo "nameserver 192.168.122.1" > /etc/resolv.conf

#### === Oropher conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.2.4
  netmask 255.255.255.0
  gateway 10.91.2.1
EOF
echo "nameserver 192.168.122.1" > /etc/resolv.conf

#### === Celebrimbor conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.2.5
  netmask 255.255.255.0
  gateway 10.91.2.1
EOF
echo "nameserver 192.168.122.1" > /etc/resolv.conf

#### === Pharazon conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
  address 10.91.2.6
  netmask 255.255.255.0
  gateway 10.91.5.1
EOF
echo "nameserver 192.168.122.1" > /etc/resolv.conf

### === Node dengan IP Dinamis/Fixed ===
# Node berikut akan dikonfigurasi untuk meminta IP dari DHCP server. Untuk sementara, resolv.conf mereka juga kita atur manual agar bisa instalasi.

#### === Gilgalad conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet dhcp
EOF
echo "nameserver 192.168.122.1" > /etc/resolv.conf

#### === Amandil conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet dhcp
EOF
echo "nameserver 192.168.122.1" > /etc/resolv.conf

#### === Khamul conf ===
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet dhcp
EOF
echo "nameserver 192.168.122.1" > /etc/resolv.conf