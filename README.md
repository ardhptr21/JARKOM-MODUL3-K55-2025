# PRAKTIKUM JARKOM MODUL 3 KELOMPOK 55 - 2025

## Angota Kelompok

| Nama                         | NRP        |
| ---------------------------- | ---------- |
| Ardhi Putra Pradana          | 5027241022 |
| M. Hikari Reiziq Rakhmadinta | 5027241079 |

## Laporan

# 🚀 Laporan Praktikum Modul 3 - Jaringan Komputer (K55)

---


### Soal 1
> Di awal Zaman Kedua, setelah kehancuran Beleriand, para Valar menugaskan untuk membangun kembali jaringan komunikasi antar kerajaan. Para Valar menyalakan Minastir, Aldarion, Erendis, Amdir, Palantir, Narvi, Elros, Pharazon, Elendil, Isildur, Anarion, Galadriel, Celeborn, Oropher, Miriel, Amandil, Gilgalad, Celebrimbor, Khamul, dan pastikan setiap node (selain Durin sang penghubung antar dunia) dapat sementara berkomunikasi dengan Valinor/Internet (nameserver 192.168.122.1) untuk menerima instruksi awal.

### Maksud dari Soal No. 1
Tujuan dari soal ini adalah untuk melakukan konfigurasi jaringan dasar pada semua node agar bisa saling terhubung dan memiliki akses ke internet. Ini adalah langkah fondasi yang krusial agar kita bisa mengunduh dan menginstall paket-paket yang diperlukan di soal-soal berikutnya (seperti `bind9`, `nginx`, dll.).

Ini dicapai dengan dua aksi utama:
1.  **Memberi Alamat IP**: Mengatur IP statis, *netmask*, dan *gateway* untuk setiap node.
2.  **Memberi Akses Internet**: Mengkonfigurasi **Durin** sebagai gerbang NAT dan mengatur DNS *resolver* di semua node lain agar menunjuk ke *nameserver* GNS3 (`192.168.122.1`).

### Cara Mengerjakan
1.  **Konfigurasi Jaringan Node**: File `/etc/network/interfaces` di **setiap node** (termasuk Durin) diatur untuk menetapkan alamat IP statis, *netmask*, dan *gateway* yang sesuai dengan topologi.
2.  **Konfigurasi IP Sementara**: Untuk node yang nantinya akan menjadi klien DHCP (Amandil, Gilgalad, Khamul), kita tetap memberikan IP statis sementara agar mereka bisa terhubung ke internet untuk instalasi awal.
3.  **Konfigurasi Router (Durin)**: File `/root/.bashrc` di Durin diedit untuk menambahkan perintah `iptables` yang mengaktifkan **NAT (Network Address Translation)**. Ini memungkinkan Durin meneruskan paket dari jaringan internal ke internet.
4.  **Konfigurasi Klien (Semua Node Lain)**: File `/root/.bashrc` di **semua 19 node lainnya** diedit untuk menambahkan perintah `echo "nameserver 192.168.122.1" > /etc/resolv.conf`. Ini memastikan semua node tahu ke mana harus bertanya untuk resolusi DNS.
5.  **Restart & Aktivasi**: Setelah semua file konfigurasi diatur, semua node di-**Stop** lalu di-**Start** dari GNS3 untuk menerapkan pengaturan `/etc/network/interfaces`. Setelah itu, login ke setiap node dan menjalankan `source /root/.bashrc` untuk mengaktifkan NAT (di Durin) dan DNS (di klien).

### Cara Melakukan Validasi
1.  **Tes Koneksi Internal**: Login ke salah satu node (misalnya **Durin**) dan lakukan `ping` ke alamat IP node di subnet lain (contoh: `ping 10.91.4.2` untuk Aldarion atau `ping 10.91.2.7` untuk Gilgalad). Jika ada balasan, routing internal melalui Durin berhasil.
2.  **Tes Koneksi Internet**: Login ke node klien (misalnya **Elendil**), jalankan `source /root/.bashrc`. Perintah `ping google.com -c 2` yang ada di dalam skrip akan otomatis berjalan. Jika `ping` berhasil, ini membuktikan bahwa NAT di Durin dan DNS *resolver* di Elendil berfungsi dengan benar.


---

## 📦 Soal 2: DHCP Server & Relay

### **Soal 2: Penyampaian Ulang**
> Raja Pelaut Aldarion, penguasa wilayah Númenor, memutuskan cara pembagian tanah client secara dinamis. Ia menetapkan:
> * Client Dinamis Keluarga Manusia: Mendapatkan tanah di rentang `[prefix ip].1.6` - `[prefix ip].1.34` dan `[prefix ip].1.68` - `[prefix ip].1.94`.
> * Client Dinamis Keluarga Peri: Mendapatkan tanah di rentang `[prefix ip].2.35` - `[prefix ip].2.67` dan `[prefix ip].2.96` - `[prefix ip].2.121`.
> * Khamul yang misterius: Diberikan tanah tetap di `[prefix ip].3.95`, agar keberadaannya selalu diketahui.
>
> Pastikan **Durin** dapat menyampaikan dekrit ini ke semua wilayah yang terhubung dengannya.

### **🎯 Maksud dari Soal No. 2**
Tujuan dari soal ini adalah mengimplementasikan sistem pembagian alamat IP otomatis menggunakan DHCP (*Dynamic Host Configuration Protocol*). Karena klien (Amandil, Gilgalad, Khamul) dan server (Aldarion) berada di jaringan yang berbeda, kita perlu membangun sistem yang lengkap:

1.  **DHCP Server (Aldarion)**: Mengkonfigurasi **Aldarion** untuk menjadi "otak" yang mengelola dan membagikan alamat IP dari daftar (*pool*) yang telah ditentukan.
2.  **DHCP Relay (Durin)**: Mengkonfigurasi **Durin** untuk bertindak sebagai perantara. Durin akan "mendengarkan" permintaan IP di jaringan klien dan meneruskannya (*relay*) ke Aldarion, lalu mengembalikan jawaban dari Aldarion ke klien yang tepat.
3.  **Fixed Address (Khamul)**: Menerapkan aturan khusus di server DHCP agar **Khamul** (berdasarkan MAC address-nya) selalu diberikan alamat IP yang sama (`10.91.3.95`), meskipun konfigurasinya di sisi klien tetap `dhcp`.

### **🛠️ Cara Mengerjakan**
1.  **Konfigurasi DHCP Server (Aldarion)**:
    * Install paket `isc-dhcp-server`.
    * Edit file `/etc/default/isc-dhcp-server` untuk menentukan `INTERFACESv4="eth0"`.
    * Edit file `/etc/dhcp/dhcpd.conf` untuk:
        * Mendefinisikan `subnet` untuk setiap jaringan klien (`10.91.1.0/24`, `10.91.2.0/24`, `10.91.3.0/24`).
        * Menambahkan `range` IP yang sesuai untuk subnet "Keluarga Manusia" dan "Keluarga Peri".
        * Menambahkan `subnet` untuk jaringan `10.91.4.0/24` (tempat Aldarion berada) agar *service* bisa berjalan.
        * Menambahkan blok `host Khamul` untuk menetapkan *Fixed Address* berdasarkan MAC address `eth0` Khamul.
    * Restart *service* `isc-dhcp-server`.

2.  **Konfigurasi DHCP Relay (Durin)**:
    * Install paket `isc-dhcp-relay`.
    * Edit file `/etc/default/isc-dhcp-relay` untuk:
        * Mengatur `SERVERS="10.91.4.2"` (alamat IP Aldarion).
        * Mengatur `INTERFACES="eth1 eth2 eth3 eth4"` (semua *interface* yang terlibat, baik ke klien maupun ke server).
    * Aktifkan *IP Forwarding* dengan mengedit file `/etc/sysctl.conf` dan menjalankan `sysctl -p`.
    * Restart *service* `isc-dhcp-relay`.

3.  **Konfigurasi Klien (Khamul, Amandil, Gilgalad)**:
    * Pada ketiga node ini, ubah file `/etc/network/interfaces` dari `inet static` menjadi `inet dhcp`.

### **✅ Cara Melakukan Validasi**
1.  **Verifikasi Layanan**:
    * Di **Aldarion**, jalankan `service isc-dhcp-server status` untuk memastikan *service* berjalan (`dhcpd is running`).
    * Di **Durin**, jalankan `ps aux | grep dhcrelay` untuk memastikan proses *relay* aktif.
2.  **Verifikasi Klien**:
    * **Restart penuh** node **Khamul**, **Amandil**, dan **Gilgalad** satu per satu dari antarmuka GNS3 (**Stop**, lalu **Start**).
    * Buka konsol setiap klien tersebut dan jalankan `ip a`.
3.  **Periksa Hasil**:
    * **Khamul** harus mendapatkan alamat `inet 10.91.3.95/24`.
    * **Amandil** harus mendapatkan alamat `inet` dari rentang `10.91.1.x` yang telah ditentukan.
    * **Gilgalad** harus mendapatkan alamat `inet` dari rentang `10.91.2.x` yang telah ditentukan.

---

## 📦 Soal 3: DNS Forwarder (Minastir)

### **Soal 3: Penyampaian Ulang**
> Untuk mengontrol arus informasi ke dunia luar (Valinor/Internet), sebuah menara pengawas, **Minastir** didirikan. Minastir mengatur agar semua node (kecuali Durin) hanya dapat mengirim pesan ke luar Arda setelah melewati pemeriksaan di Minastir.

### **🎯 Maksud dari Soal No. 3**
Tujuan dari soal ini adalah untuk mengubah alur resolusi DNS di seluruh jaringan. Kita akan menjadikan **Minastir** sebagai **DNS Forwarder**.

Artinya, semua node lain (klien statis dan dinamis) yang ingin mengetahui alamat IP dari sebuah domain (misalnya `google.com`) tidak akan lagi bertanya langsung ke internet (`192.168.122.1`), melainkan harus bertanya ke Minastir (`10.91.5.2`). Minastir kemudian akan meneruskan (*forward*) permintaan tersebut ke server DNS di internet, menerima jawabannya, lalu mengirimkan jawaban itu kembali ke node yang bertanya.

### **🛠️ Cara Mengerjakan**
1.  **Konfigurasi Minastir (DNS Forwarder)**:
    * Install paket `bind9`.
    * Edit file `/etc/bind/named.conf.options` untuk mengaktifkan `listen-on { any; }` (agar mau menerima koneksi dari jaringan), `allow-recursion { ... 10.91.0.0/16; }` (agar mau bekerja untuk jaringan internal kita), dan `forwarders { 192.168.122.1; }` (agar tahu ke mana harus meneruskan permintaan).
    * Ubah file `/etc/resolv.conf` milik Minastir sendiri ke `192.168.122.1` untuk mencegah *looping*.
    * Restart *service* `named`.

    ![Konfigurasi BIND9 di Minastir](assets/3_install_bind_minastir.png)

2.  **Konfigurasi Ulang Aldarion (DHCP Server)**:
    * Edit file `/etc/dhcp/dhcpd.conf` di Aldarion.
    * Ubah nilai `option domain-name-servers` dari yang lama menjadi alamat IP Minastir (`10.91.5.2`). Ini akan secara otomatis memberitahu semua klien dinamis untuk menggunakan Minastir.
    * Restart *service* `isc-dhcp-server` untuk menerapkan perubahan.

3.  **Konfigurasi Ulang Klien Dinamis (Khamul, Amandil, Gilgalad)**:
    * Hapus baris `echo "nameserver 192.168.122.1" ...` dari file `/root/.bashrc` mereka. Ini penting agar skrip `.bashrc` tidak menimpa konfigurasi DNS yang didapat dari DHCP.

4.  **Konfigurasi Ulang Klien Statis (Elendil, Isildur, dll.)**:
    * Edit file `/root/.bashrc` di semua node ini.
    * Ganti baris `echo "nameserver 192.168.122.1" ...` dengan `echo "nameserver 10.91.5.2" > /etc/resolv.conf`.
    * Jalankan `source /root/.bashrc` di setiap node tersebut untuk menerapkan perubahan.

### **✅ Cara Melakukan Validasi**
1.  **Validasi Klien Statis (Contoh: Elendil)**:
    * Setelah menjalankan `source /root/.bashrc`, jalankan `cat /etc/resolv.conf`. Pastikan outputnya adalah `nameserver 10.91.5.2`.
    * Lakukan tes `ping google.com`. Jika berhasil, validasi sukses.

    ![Konfigurasi DNS Klien Statis (Elendil)](assets/3_new_name_server_elendil.png)
    ![Hasil Ping Klien Statis (Elendil)](assets/3_test_ping_elendil.png)

2.  **Validasi Klien Dinamis (Contoh: Khamul)**:
    * **Restart penuh node Khamul** dari antarmuka GNS3 (**Stop**, lalu **Start**).
    * Setelah node menyala, login dan jalankan `cat /etc/resolv.conf`. Outputnya **harus** `nameserver 10.91.5.2` (ini didapat secara otomatis dari Aldarion).
    * Lakukan tes `ping google.com`. Jika berhasil, validasi sukses.

    ![Hasil Validasi Klien Dinamis (Khamul)](assets/3_test_ping_and_IP_khamul.png)

