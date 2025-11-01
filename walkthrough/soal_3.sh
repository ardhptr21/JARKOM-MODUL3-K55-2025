# ==== ALDARION: Perbaikan Final dan Bersih untuk dhcpd.conf ====

cat <<EOF > /etc/dhcp/dhcpd.conf
# Jadikan server ini sebagai satu-satunya sumber DHCP yang sah
authoritative;

# Opsi global untuk semua klien: arahkan DNS ke Minastir
option domain-name-servers 10.91.5.2;

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

# Konfigurasi IP tetap (Fixed Address) untuk Khamul dengan MAC Address BARU
host Khamul {
  hardware ethernet 02:42:e8:63:34:00;
  fixed-address 10.91.3.95;
}
EOF

# Restart service DHCP. Kali ini seharusnya bersih.
service isc-dhcp-server restart

# ==== MINASTIR: Konfigurasi Final BIND9 ====
apt-get update && apt-get install -y bind9

cat <<EOF > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    listen-on { any; };
    listen-on-v6 { any; };
    allow-query { any; };
    allow-recursion { localhost; 10.91.0.0/16; };

    forwarders {
        192.168.122.1;
    };
    forward only;
};
EOF

echo "nameserver 192.168.122.1" > /etc/resolv.conf
service named restart


# ==== SEMUA NODE (KECUALI DURIN & MINASTIR): Arahkan DNS ke Minastir ====
# Jalankan di: Aldarion, Erendis, Amdir, Palantir, Narvi, Elros, Pharazon,
# Elendil, Isildur, Anarion, Galadriel, Celeborn, Oropher, Miriel,
# Amandil, Gilgalad, Celebrimbor, dan Khamul.

# Mengatur DNS resolver agar menunjuk ke Minastir
echo "nameserver 10.91.5.2" > /etc/resolv.conf

# Di Klien Dinamis (Khamul, Amandil, dan Gilgalad)

# Jalankan perintah ini di Khamul, Amandil, dan Gilgalad. 
# Perintah ini akan mencari baris yang mengandung "nameserver" di dalam file .bashrc dan menghapusnya secara otomatis.

# Menghapus baris konfigurasi DNS yang lama dari .bashrc
sed -i '/nameserver/d' /root/.bashrc #untuk dijalankan perintah ini di Khamul, Amandil, dan Gilgalad

# Pastikan Aldarion dan Minastir sudah berjalan dengan konfigurasi terakhir yang benar (dari jawaban sebelumnya).

# Restart penuh node Khamul,Amandil, dan Gilgalad dari GNS3 (Stop, lalu Start). Ini sangat penting. Lalu jalankan cat /etc/resolv.conf outputnya pasti akan secara otomatis menunjukkan nameserver 10.91.5.2.
