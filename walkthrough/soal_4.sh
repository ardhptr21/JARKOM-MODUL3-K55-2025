# === Erendis (DNS Master) ===
# 1. Install paket BIND9
apt-get update
apt-get install -y bind9

# 2. Konfigurasi opsi BIND9, termasuk izin transfer ke Amdir
cat <<EOF > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    listen-on { any; };
    listen-on-v6 { any; };
    allow-query { any; };
    allow-recursion { localhost; 10.91.0.0/16; };
    
    // Izinkan Amdir (10.91.3.3) untuk menyalin zone
    allow-transfer { 10.91.3.3; };

    // Tetap butuh forwarder untuk domain luar (misal: google.com)
    forwarders { 192.168.122.1; };
};
EOF

# 3. Deklarasikan zone K55.com sebagai master
cat <<EOF > /etc/bind/named.conf.local
zone "K55.com" {
    type master;
    file "/etc/bind/jarkom/K55.com";
    allow-transfer { 10.91.3.3; };
};
EOF

# 4. Buat direktori untuk zone file
mkdir -p /etc/bind/jarkom

# 5. Buat zone file K55.com dengan semua record yang dibutuhkan
cat <<EOF > /etc/bind/jarkom/K55.com
\$TTL    604800
@       IN      SOA     K55.com. root.K55.com. (
                        2025103101      ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
; Name Servers
@       IN      NS      ns1.K55.com.
@       IN      NS      ns2.K55.com.

; Name Server A records
ns1     IN      A       10.91.3.2       ; IP Erendis
ns2     IN      A       10.91.3.3       ; IP Amdir

; Host A records
palantir  IN    A       10.91.4.4
elros     IN    A       10.91.1.6
pharazon  IN    A       10.91.2.6
elendil   IN    A       10.91.1.2
isildur   IN    A       10.91.1.3
anarion   IN    A       10.91.1.4
galadriel IN    A       10.91.2.2
celeborn  IN    A       10.91.2.3
oropher   IN    A       10.91.2.4
EOF

# 6. Restart service BIND9
service named restart



# === Amdir (DNS Slave) ===
# 1. Install paket BIND9
apt-get update
apt-get install -y bind9

# 2. Konfigurasi opsi BIND9 (tidak perlu allow-transfer di sini)
cat <<EOF > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    listen-on { any; };
    listen-on-v6 { any; };
    allow-query { any; };
    allow-recursion { localhost; 10.91.0.0/16; };

    forwarders { 192.168.122.1; };
};
EOF

# 3. Deklarasikan zone K55.com sebagai slave
cat <<EOF > /etc/bind/named.conf.local
zone "K55.com" {
    type slave;
    masters { 10.91.3.2; }; // Alamat IP Erendis (Master)
    file "/var/lib/bind/K55.com";
};
EOF

# 4. Restart service BIND9
service named restart

# ==== ALDARION (DHCP Server): Perbarui DNS Server untuk Klien Dinamis ====

cat <<EOF > /etc/dhcp/dhcpd.conf
# Jadikan server ini sebagai satu-satunya sumber DHCP yang sah
authoritative;

# Opsi global: Arahkan DNS ke Erendis (utama) dan Amdir (cadangan)
option domain-name-servers 10.91.3.2, 10.91.3.3;

# Definisi subnet... (sisanya tetap sama)
subnet 10.91.1.0 netmask 255.255.255.0 {
  range 10.91.1.6 10.91.1.34;
  range 10.91.1.68 10.91.1.94;
  option routers 10.91.1.1;
  option broadcast-address 10.91.1.255;
}
subnet 10.91.2.0 netmask 255.255.255.0 {
  range 10.91.2.35 10.91.2.67;
  range 10.91.2.96 10.91.2.121;
  option routers 10.91.2.1;
  option broadcast-address 10.91.2.255;
}
subnet 10.91.3.0 netmask 255.255.255.0 {
  option routers 10.91.3.1;
  option broadcast-address 10.91.3.255;
}
subnet 10.91.4.0 netmask 255.255.255.0 {
}
host Khamul {
  hardware ethernet 02:42:e8:63:34:00;
  fixed-address 10.91.3.95;
}
EOF

# Restart service DHCP
service isc-dhcp-server restart

# Di Semua Klien Statis (Elendil, Isildur, Miriel, elros, Galadriel, Celeborn, Oropher, celebrimbor, pharazon, palantir, narvi, minastir):
# Hapus konfigurasi DNS yang lama dari .bashrc
sed -i '/nameserver/d' /root/.bashrc

# Tambahkan konfigurasi DNS yang baru (menunjuk ke Erendis & Amdir)
echo 'echo -e "nameserver 10.91.3.2\nnameserver 10.91.3.3" > /etc/resolv.conf' >> /root/.bashrc

# Terapkan perubahan sekarang
source /root/.bashrc