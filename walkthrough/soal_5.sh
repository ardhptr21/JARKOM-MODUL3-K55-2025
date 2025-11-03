# === Erendis (DNS Master) ===
# 1. Tambahkan deklarasi reverse zone ke named.conf.local
# Kita menggunakan 'tee -a' untuk menambahkan teks tanpa menghapus yang sudah ada.
cat <<EOF | tee -a /etc/bind/named.conf.local

zone "3.91.10.in-addr.arpa" {
    type master;
    file "/etc/bind/jarkom/3.91.10.in-addr.arpa";
};
EOF

# 2. Buat file zone untuk reverse lookup
cat <<EOF > /etc/bind/jarkom/3.91.10.in-addr.arpa
\$TTL    604800
@       IN      SOA     K55.com. root.K55.com. (
                        2025103101      ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns1.K55.com.
@       IN      NS      ns2.K55.com.
2       IN      PTR     ns1.K55.com.    ; 10.91.3.2 -> ns1.K55.com.
3       IN      PTR     ns2.K55.com.    ; 10.91.3.3 -> ns2.K55.com.
EOF

# 3. Tambahkan record CNAME dan TXT ke zone file K55.com
# Kita menggunakan 'tee -a' lagi untuk menambahkan di akhir file.
cat <<EOF | tee -a /etc/bind/jarkom/K55.com

; Alias for the main domain
www     IN      CNAME   K55.com.

; TXT Records
@       IN      TXT     "Cincin Sauron=elros.K55.com"
@       IN      TXT     "Aliansi Terakhir=pharazon.K55.com"
EOF

# 4. Restart service BIND9 untuk menerapkan semua perubahan
service named restart

# === Amdir (Slave) ====

cat <<EOF | tee -a /etc/bind/named.conf.local
zone "3.91.10.in-addr.arpa" {
    type slave;
    file "/var/lib/bind/3.91.10.in-addr.arpa";
    masters { 10.91.3.2; };
};
EOF

service named restart

# check and test reverse lookup
dig @10.91.3.2 -x 10.91.3.2
dig @10.91.3.3 -x 10.91.3.3