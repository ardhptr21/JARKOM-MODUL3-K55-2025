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

---

## 📦 Soal 4: DNS Master-Slave (Erendis & Amdir)

### **Soal 4: Penyampaian Ulang**
> Ratu Erendis, sang pembuat peta, menetapkan nama resmi untuk wilayah utama (`K55.com`). Ia menunjuk dirinya (`ns1.K55.com`) dan muridnya Amdir (`ns2.K55.com`) sebagai penjaga peta resmi. Setiap lokasi penting (Palantir, Elros, Pharazon, Elendil, Isildur, Anarion, Galadriel, Celeborn, Oropher) diberikan nama domain unik yang menunjuk ke lokasi fisik tanah mereka. Pastikan Amdir selalu menyalin peta (*master-slave*) dari Erendis dengan setia.

### **🎯 Maksud dari Soal No. 4**
Tujuan dari soal ini adalah membangun sistem DNS internal kita sendiri untuk mengelola domain `K55.com`. Ini menggantikan peran Minastir sebagai *forwarder* sederhana.
1.  **Erendis sebagai DNS Master Server**: Erendis dikonfigurasi sebagai sumber utama ("master") yang menyimpan *database* (disebut *zone file*) yang memetakan semua nama domain (`elros.K55.com`) ke alamat IP (`10.91.1.6`).
2.  **Amdir sebagai DNS Slave Server**: Amdir dikonfigurasi sebagai server cadangan ("slave"). Ia akan secara otomatis menyalin seluruh *database* dari Erendis. Ini adalah mekanisme replikasi yang penting untuk ketersediaan layanan (jika Erendis mati, Amdir bisa mengambil alih).
3.  **Pembaruan Klien**: Semua node di jaringan (baik statis maupun dinamis) harus diperbarui agar tidak lagi bertanya ke Minastir, melainkan bertanya ke Erendis (`10.91.3.2`) dan Amdir (`10.91.3.3`).

### **🛠️ Cara Mengerjakan**
1.  **Konfigurasi Erendis (Master)**:
    * Install `bind9`.
    * Edit file `/etc/bind/named.conf.options` untuk mengizinkan *query*, *recursion*, dan `allow-transfer` ke Amdir.
    * Edit file `/etc/bind/named.conf.local` untuk mendeklarasikan *zone* `K55.com` sebagai `type master`.
    * Buat file *zone* `/etc/bind/jarkom/K55.com` yang berisi semua *record* SOA, NS, dan A untuk semua *host* yang diminta.
    * Restart *service* `named`.

    ![Konfigurasi Erendis (Master)](assets/4_konfig_erendis.png)

2.  **Konfigurasi Amdir (Slave)**:
    * Install `bind9`.
    * Edit file `/etc/bind/named.conf.options` untuk mengizinkan *query* dan *recursion*.
    * Edit file `/etc/bind/named.conf.local` untuk mendeklarasikan *zone* `K55.com` sebagai `type slave`, menunjuk ke `masters { 10.91.3.2; }` (IP Erendis).
    * Restart *service* `named`.

    ![Konfigurasi Amdir (Slave)](assets/4_konfig_amdir.png)

3.  **Konfigurasi Ulang Klien Dinamis**:
    * Edit file `/etc/dhcp/dhcpd.conf` di **Aldarion**.
    * Ubah baris `option domain-name-servers` agar sekarang berisi IP Erendis dan Amdir (`10.91.3.2, 10.91.3.3`).
    * Restart *service* `isc-dhcp-server`.

    ![Pembaruan DNS Server di Aldarion (DHCP)](assets/4_perbarui_dns%20server_aldarion.png)

4.  **Konfigurasi Ulang Klien Statis**:
    * Di semua node statis (Elendil, Minastir, Palantir, dll.), edit file `/root/.bashrc`.
    * Hapus baris lama yang menunjuk ke Minastir.
    * Tambahkan baris baru: `echo -e "nameserver 10.91.3.2\nnameserver 10.91.3.3" > /etc/resolv.conf`.
    * Jalankan `source /root/.bashrc` untuk menerapkan perubahan.

### **✅ Cara Melakukan Validasi**
1.  **Validasi Replikasi (di Amdir)**:
    * Jalankan `ls -l /var/lib/bind/` di Amdir. Pastikan file `K55.com` telah berhasil dibuat. Ini membuktikan *zone transfer* dari Erendis berhasil.
    * (Dapat dilihat pada gambar konfigurasi Amdir di atas)

2.  **Validasi Klien Statis (di Elendil)**:
    * Jalankan `cat /etc/resolv.conf` untuk memastikan *nameserver* telah menunjuk ke Erendis dan Amdir.
    * Tes resolusi internal: `host elros.K55.com`. Pastikan hasilnya adalah `10.91.1.6`.
    * Tes resolusi eksternal: `ping google.com -c 2`. Pastikan *forwarding* masih berfungsi.

    ![Validasi Klien Statis (Elendil)](assets/4_validation_host_from_elendil.png)

3.  **Validasi Klien Dinamis (di Khamul)**:
    * **Restart penuh node Khamul** dari GNS3 (Stop, lalu Start).
    * Jalankan `cat /etc/resolv.conf`. Pastikan `nameserver 10.91.3.2` dan `nameserver 10.91.3.3` muncul **secara otomatis**.
    * Tes resolusi internal: `host pharazon.K55.com`.

    ![Validasi resolv.conf Klien Dinamis (Khamul)](assets/4_bukti_nameserver_khamul.png)


---

## 📦 Soal 5: Menambahkan Record CNAME, PTR, dan TXT

### **Soal 5: Penyampaian Ulang**
> Untuk memudahkan, nama alias `www.K55.com` dibuat untuk peta utama `K55.com`. **Reverse PTR** juga dibuat agar lokasi Erendis dan Amdir dapat dilacak dari alamat fisik tanahnya. Erendis juga menambahkan pesan rahasia (**TXT record**) pada petanya: "Cincin Sauron" yang menunjuk ke lokasi Elros, dan "Aliansi Terakhir" yang menunjuk ke lokasi Pharazon. Pastikan Amdir juga mengetahui pesan rahasia ini.

### **🎯 Maksud dari Soal No. 5**
Soal ini meminta kita untuk menambahkan tiga jenis *record* DNS baru di server master (**Erendis**). Karena Amdir adalah *slave*, semua perubahan ini akan **otomatis tersalin** kepadanya.
1.  **CNAME (Canonical Name)**: Ini adalah "nama panggilan" atau alias. Kita akan membuat `www.K55.com` sebagai alias yang akan menunjuk ke `K55.com`.
2.  **PTR (Pointer Record)**: Ini adalah kebalikan dari *record A* (yang memetakan Nama ke IP). PTR memetakan **IP ke Nama**. Ini sering disebut *Reverse DNS* atau *reverse lookup*, dan berguna untuk "mencari tahu siapa pemilik" sebuah alamat IP.
3.  **TXT (Text Record)**: Ini adalah *record* yang memungkinkan kita menyimpan teks biasa di dalam DNS untuk "pesan rahasia".

### **🛠️ Cara Mengerjakan**
Seluruh konfigurasi untuk soal ini hanya dilakukan di **Erendis (Master Server)**.
1.  **Deklarasikan Reverse Zone**: Di file `/etc/bind/named.conf.local`, kita mendeklarasikan zona baru untuk *reverse lookup* jaringan `10.91.3.0/24`. Nama zona ini memiliki format khusus: `3.91.10.in-addr.arpa`.

    ![Deklarasi Reverse Zone di Erendis](assets/5_reverse_zone_erendis.png)

2.  **Buat Zone File**: Kita membuat file baru (`/etc/bind/jarkom/3.91.10.in-addr.arpa`) yang berisi pemetaan PTR untuk Erendis dan Amdir.
3.  **Perbarui Zone File**: Kita mengedit file `K55.com` yang sudah ada untuk menambahkan *record* CNAME (`www`) dan dua *record* TXT.
4.  **Restart BIND9**: Terapkan semua perubahan dengan me-restart *service* `named` di Erendis.

    ![Pembuatan Reverse Zone File dan Penambahan CNAME/TXT](assets/5_reverse_lookup_erendis.png)

### **✅ Cara Melakukan Validasi**
Setelah menjalankan skrip di **Erendis**, kita bisa langsung melakukan validasi dari klien mana pun (misalnya, **Elendil** atau **Khamul**) yang sudah menggunakan Erendis/Amdir sebagai DNS servernya.

1.  **Validasi CNAME**:
    * Jalankan `host www.K55.com`.
    * Hasil: `www.K55.com is an alias for K55.com.`
2.  **Validasi PTR (Reverse Lookup)**:
    * Jalankan `host 10.91.3.2`.
    * Hasil: `2.3.91.10.in-addr.arpa domain name pointer ns1.K55.com.`
3.  **Validasi TXT**:
    * Jalankan `host -t TXT K55.com`.
    * Hasil: Menampilkan kedua *record* TXT, "Cincin Sauron..." dan "Aliansi Terakhir...".

Semua validasi ini berhasil dilakukan dari klien, yang membuktikan bahwa konfigurasi telah berhasil diterapkan dan disalin ke *slave*.

![Validasi Lengkap dari Klien (Elendil)](assets/5_validasi_elendil.png)

---

## 📦 Soal 6: Konfigurasi DHCP Lease Time

### **Soal 6: Penyampaian Ulang**
> Aldarion menetapkan aturan waktu peminjaman tanah. Ia mengatur:
> * Client Dinamis Keluarga Manusia dapat meminjam tanah selama **setengah jam**.
> * Client Dinamis Keluarga Peri hanya **seperenam jam**.
> * Batas waktu maksimal peminjaman untuk semua adalah **satu jam**.

### **🎯 Maksud dari Soal No. 6**
Tujuan dari soal ini adalah untuk mengatur **durasi peminjaman alamat IP** (*Lease Time*) yang dibagikan oleh server DHCP **Aldarion**. Kita perlu menetapkan durasi yang berbeda untuk subnet yang berbeda sesuai permintaan soal.

* Setengah jam = 30 menit = **1800 detik**
* Seperenam jam = 10 menit = **600 detik**
* Satu jam = 60 menit = **3600 detik**

Ini dilakukan untuk mengontrol seberapa lama sebuah klien dapat "memegang" sebuah alamat IP sebelum harus melapor kembali ke server untuk memperpanjangnya.

### **🛠️ Cara Mengerjakan**
Seluruh konfigurasi untuk soal ini hanya dilakukan di **Aldarion (DHCP Server)**.
1.  Edit file konfigurasi `/etc/dhcp/dhcpd.conf`.
2.  Di dalam blok `subnet 10.91.1.0` (Keluarga Manusia), tambahkan direktif `default-lease-time 1800;` dan `max-lease-time 3600;`.
3.  Di dalam blok `subnet 10.91.2.0` (Keluarga Peri), tambahkan direktif `default-lease-time 600;` dan `max-lease-time 3600;`.
4.  Pastikan tidak ada *syntax error* akibat kesalahan salin-tempel (masalah yang sering terjadi sebelumnya).
5.  Restart *service* `isc-dhcp-server` untuk menerapkan semua perubahan konfigurasi.

![Konfigurasi Lease Time di Aldarion](assets/6_dhcp_lease_time_aldarion.png)

### **✅ Cara Melakukan Validasi**
1.  **Validasi Server**: Di **Aldarion**, jalankan `service isc-dhcp-server status` untuk memastikan *service* `dhcpd is running`. Ini membuktikan bahwa file konfigurasi baru kita valid dan telah berhasil dimuat.
2.  **Validasi Klien (Keluarga Manusia)**:
    * **Restart penuh node Amandil** dari antarmuka GNS3 (**Stop**, lalu **Start**).
    * Saat node *booting*, perhatikan log `udhcpc`. Log harus menunjukkan `lease time 1800`.
3.  **Validasi Klien (Keluarga Peri)**:
    * **Restart penuh node Gilgalad** dari GNS3.
    * Saat node *booting*, log `udhcpc` harus menunjukkan `lease time 600`.

Hasil validasi di Amandil menunjukkan *lease time* yang benar, yaitu 1800 detik, yang membuktikan bahwa konfigurasi telah berhasil diterapkan.

![Validasi Lease Time di Amandil](assets/6_lease_time_amandil.png)

---

## 📦 Soal 7: Setup Worker Laravel (Elendil, Isildur, Anarion)

### **Soal 7: Penyampaian Ulang**
> Para Ksatria Númenor (Elendil, Isildur, Anarion) mulai membangun benteng pertahanan digital mereka menggunakan teknologi Laravel. Instal semua *tools* yang dibutuhkan (`php8.4`, `composer`, `nginx`) dan dapatkan cetak biru benteng dari `Resource-laravel` di setiap node *worker* Laravel. Cek dengan `lynx` di client.

### **🎯 Maksud dari Soal No. 7**
Tujuan dari soal ini adalah melakukan instalasi dan konfigurasi lengkap pada tiga node *worker* kita: **Elendil, Isildur, dan Anarion**. Masing-masing node ini akan disiapkan sebagai *server* web independen yang menjalankan aplikasi Laravel. Ini adalah langkah persiapan fondasi sebelum kita menghubungkan mereka ke *database* dan *load balancer* di soal-soal berikutnya.

### **🛠️ Cara Mengerjakan**
Proses ini diulangi di ketiga node *worker* (Elendil, Isildur, Anarion).
1.  **Installasi Paket**: Pertama, kita menambahkan repositori `sury.org` untuk mendapatkan versi PHP yang spesifik. Kemudian, kita menginstall semua paket yang dibutuhkan, termasuk `nginx`, `git`, `composer`, dan `php8.4` beserta ekstensi-ekstensinya.
2.  **Unduh Aplikasi Laravel**: Berpindah ke direktori `/var/www` dan menggunakan `git clone` untuk mengunduh kode aplikasi dari repositori `laravel-simple-rest-api`.
3.  **Install Dependensi (Perbaikan)**:
    * Saat menjalankan `composer install`, terjadi error karena `composer.lock` dari repositori tersebut meminta paket-paket lama yang tidak kompatibel dengan PHP 8.4.
    * **Solusi**: Sebagai gantinya, kita menjalankan `composer update`. Perintah ini akan mengabaikan file `.lock` dan mengunduh versi terbaru dari semua paket yang kompatibel dengan PHP 8.4.
4.  **Konfigurasi Dasar Laravel**: Menyalin file `.env.example` menjadi `.env` dan menjalankan `php artisan key:generate` untuk membuat kunci enkripsi aplikasi.
5.  **Konfigurasi Nginx**: Membuat file konfigurasi *server block* baru di `/etc/nginx/sites-available/laravel`. Di dalam file ini, kita mengatur `root` ke direktori `.../public` aplikasi Laravel dan mengatur `listen` pada port yang unik untuk setiap *worker* (Elendil: 8001, Isildur: 8002, Anarion: 8003).
6.  **Finalisasi**: Mengaktifkan situs Nginx yang baru dengan membuat *symlink* ke `sites-enabled` dan menghapus konfigurasi *default*. Izin akses folder `storage` juga diatur, lalu *service* `php8.4-fpm` dan `nginx` dijalankan.

### **✅ Cara Melakukan Validasi**
1.  **Install Lynx**: Di node klien (misalnya **Miriel**), install `lynx` untuk melakukan tes berbasis teks.
2.  **Akses Setiap Worker**: Gunakan `lynx` untuk mengakses setiap *worker* melalui alamat IP dan port-nya masing-masing.
    * `lynx http://10.91.1.2:8001` (Elendil)
    * `lynx http://10.91.1.3:8002` (Isildur)
    * `lynx http://10.91.1.4:8003` (Anarion)
3.  **Periksa Hasil**: Validasi dianggap **berhasil** jika `lynx` menampilkan halaman selamat datang Laravel, bukan halaman error "500 Internal Server Error".

    ![Validasi Berhasil di Isildur](assets/7_tes_laravel_isildur.png)


---

## 📦 Soal 8: Koneksi Database & Pembatasan Domain

### **Soal 8: Penyampaian Ulang**
> Setiap benteng Númenor harus terhubung ke sumber pengetahuan, **Palantir**. Konfigurasikan koneksi database di file **.env** masing-masing worker. Setiap benteng juga harus memiliki gerbang masuk yang unik; atur nginx agar **Elendil mendengarkan di port 8001, Isildur di 8002, dan Anarion di 8003**. Jangan lupa jalankan **migrasi dan seeding** awal dari **Elendil**. Buat agar akses web hanya bisa melalui **domain nama**, tidak bisa melalui ip.

### **🎯 Maksud dari Soal No. 8**
Tujuan dari soal ini adalah untuk "menghidupkan" aplikasi Laravel yang sudah kita install di Soal 7. Ini dilakukan dengan menghubungkan ketiga *worker* (Elendil, Isildur, Anarion) ke satu *database server* pusat, yaitu **Palantir**.

Kita akan melakukan empat hal:
1.  **Menyiapkan Database Pusat**: Mengkonfigurasi **Palantir** (MariaDB) agar siap menerima koneksi dari *worker*.
2.  **Menghubungkan Worker**: Memberi tahu setiap *worker* (via file `.env`) alamat dan kredensial untuk mengakses *database* di Palantir.
3.  **Inisialisasi Database**: Menjalankan *migrasi* (`php artisan migrate`) dari Elendil untuk membangun struktur tabel di Palantir dan *seeding* (`db:seed`) untuk mengisinya dengan data awal.
4.  **Membatasi Akses**: Mengubah konfigurasi Nginx di setiap *worker* agar mereka **hanya merespon** jika diakses menggunakan nama domain (misal, `elendil.K55.com`) dan menolak akses via alamat IP (`10.91.1.2`).

### **🛠️ Cara Mengerjakan**
1.  **Konfigurasi Palantir (Database Server)**:
    * Install `mariadb-server`.
    * Membuat *database* baru (misal, `db_k55`) dan *user* (misal, `k55_user`) dengan hak akses penuh dari jaringan *worker*.
    * **(Perbaikan Penting)** Mengedit file konfigurasi MariaDB (di `/etc/mysql/mariadb.conf.d/50-server.cnf`) untuk **mengomentari** baris `bind-address = 127.0.0.1`. Ini adalah langkah krusial agar server mau menerima koneksi dari alamat IP lain (Elendil, dkk.), tidak hanya dari `localhost`.
    * Me-restart *service* `mariadb`.

2.  **Konfigurasi Worker (Elendil, Isildur, & Anarion)**:
    * Pada ketiga node, edit file `/var/www/laravel-simple-rest-api/.env`.
    * Ubah nilai `DB_HOST`, `DB_DATABASE`, `DB_USERNAME`, dan `DB_PASSWORD` agar sesuai dengan yang dibuat di Palantir.

3.  **Migrasi & Seeding (Hanya Elendil)**:
    * Setelah Palantir siap dan `.env` di Elendil terkonfigurasi, kita masuk ke direktori aplikasi di **Elendil**.
    * Menjalankan `php artisan migrate:fresh` untuk membuat semua tabel di *database* Palantir.
    * Menjalankan `php artisan db:seed --class=AiringsTableSeeder` untuk mengisi data awal ke tabel `airings`.

4.  **Konfigurasi Nginx (Domain Only)**:
    * Di **Elendil**, edit `/etc/nginx/sites-available/laravel` dan ubah `server_name _;` menjadi `server_name elendil.K55.com;`.
    * Di **Isildur**, lakukan hal yang sama, tetapi ubah menjadi `server_name isildur.K55.com;`.
    * Di **Anarion**, lakukan hal yang sama, tetapi ubah menjadi `server_name anarion.K55.com;`.
    * Restart `nginx` di ketiga *worker*.

### **✅ Cara Melakukan Validasi**
1.  **Validasi Database (di Palantir)**:
    * Setelah *service* MariaDB di-restart, jalankan `netstat -tulpn | grep 3306`.
    * Hasilnya harus menunjukkan bahwa *service* `mariadbd` mendengarkan di `0.0.0.0:3306` atau `:::3306`, bukan lagi `127.0.0.1:3306`. Ini membuktikan ia siap menerima koneksi jaringan.

    ![Validasi Port MariaDB di Palantir](assets/8_mariaDB.png)

2.  **Validasi Migrasi (di Elendil)**:
    * Periksa output dari `php artisan migrate:fresh`. Perintah ini harus berjalan sukses dengan status `DONE` untuk setiap tabel dan tidak ada error `Connection refused`.

    ![Validasi Migrasi Berhasil di Elendil](assets/8_migrasi.png)

3.  **Validasi Akses Domain (di Klien)**:
    * Buka klien (misal, **Miriel**).
    * Jalankan `lynx http://elendil.K55.com:8001`.
    * Tes ini harus **berhasil** dan menampilkan halaman Laravel, membuktikan Nginx merespon panggilan via domain.

    ![Validasi Lynx via Domain Berhasil](assets/8_lynx_http_elendil_k55_com.png)

4.  **Validasi Akses IP (di Klien)**:
    * Dari klien yang sama, jalankan `lynx http://10.91.1.2:8001`.
    * Tes ini seharusnya **GAGAL** (misal, menampilkan error 404), membuktikan Nginx sudah tidak merespon panggilan via IP.



---

## 📦 Soal 9: Validasi Worker Laravel dan Database

### **Soal 9: Penyampaian Ulang**
> Pastikan setiap benteng berfungsi secara mandiri. Dari dalam node client masing-masing, gunakan `lynx` untuk melihat halaman utama Laravel dan `curl /api/airing` untuk memastikan mereka bisa mengambil data dari Palantir.

### **🎯 Maksud dari Soal No. 9**
Soal ini adalah langkah pengujian akhir untuk memastikan bahwa semua konfigurasi dari Soal 7 dan 8 telah berhasil. Tujuannya adalah untuk memvalidasi dua hal dari perspektif klien:
1.  **Fungsionalitas Web Server**: Membuktikan bahwa *worker* (Elendil, Isildur, Anarion) dapat diakses melalui nama domain dan port-nya masing-masing. Ini divalidasi menggunakan `lynx`.
2.  **Konektivitas Database**: Membuktikan bahwa aplikasi Laravel di setiap *worker* dapat terhubung ke *database* **Palantir**, mengambil data yang telah di-*seed*, dan menampilkannya. Ini divalidasi menggunakan `curl` ke *endpoint* API (`/api/airing`).

### **🛠️ Cara Mengerjakan**
Semua langkah pengerjaan pada soal ini adalah perintah validasi yang dijalankan dari **node klien** (misalnya, **Miriel**).
1.  **Siapkan Klien**: Pastikan node klien (Miriel) memiliki *tools* `lynx` dan `curl` yang sudah terinstall.
2.  **Pastikan DNS Klien**: Pastikan file `/etc/resolv.conf` di Miriel sudah menunjuk ke server DNS Erendis (`10.91.3.2`) dan Amdir (`10.91.3.3`).
3.  **Jalankan Tes `lynx`**: Jalankan `lynx -dump` ke halaman utama setiap *worker* (misal, `lynx -dump http://isildur.K55.com:8002`) untuk memeriksa apakah *web server* merespon.
4.  **Jalankan Tes `curl`**: Jalankan `curl` ke *endpoint* `/api/airing` di setiap *worker* (misal, `curl http://isildur.K55.com:8002/api/airing`) untuk memeriksa apakah koneksi *database* berfungsi.

### **✅ Cara Melakukan Validasi**
1.  **Validasi Halaman Utama (`lynx`)**:
    * Perintah `lynx -dump` ke setiap *worker* (Elendil, Isildur, Anarion) berhasil mengembalikan halaman selamat datang Laravel. Ini membuktikan Soal 7 (setup `nginx`/`php-fpm`) dan bagian pembatasan domain dari Soal 8 berhasil.

    ![Validasi Lynx Berhasil di Isildur](assets/9_uji_lynx_isildur.png)

2.  **Validasi API Database (`curl`)**:
    * Perintah `curl` ke *endpoint* `/api/airing` di setiap *worker* berhasil mengembalikan data dalam format JSON yang diawali dengan `{"data":[{...` dan diakhiri `,"message":"succeed"}`.
    * Ini adalah bukti mutlak bahwa Soal 8 (konfigurasi `.env`, `bind-address` di Palantir, dan proses `migrate:fresh --seed`) telah **berhasil dengan sukses**.

    ![Validasi API (Database) Berhasil di Semua Worker](assets/9_uji_api_elendil_isildur_anarion.png)


---

## 📦 Soal 10: Konfigurasi Load Balancer (Elros)

### **Soal 10: Penyampaian Ulang**
> Pemimpin bijak Elros ditugaskan untuk mengkoordinasikan pertahanan Númenor. Konfigurasikan nginx di **Elros** untuk bertindak sebagai **reverse proxy**. Buat *upstream* bernama **kesatria_numenor** yang berisi alamat ketiga *worker* (Elendil, Isildur, Anarion). Atur agar semua permintaan yang datang ke domain **elros.K55.com** diteruskan secara merata menggunakan algoritma **Round Robin** ke *backend*.

### **🎯 Maksud dari Soal No. 10**
Tujuan dari soal ini adalah untuk menyiapkan **Load Balancer**. Node **Elros** akan bertindak sebagai "gerbang utama" atau *reverse proxy* untuk ketiga *worker* Laravel kita.

Daripada klien harus mengingat tiga alamat port yang berbeda (8001, 8002, 8003), mereka sekarang hanya perlu mengakses satu alamat: `http://elros.K55.com`. Elros kemudian akan secara cerdas meneruskan permintaan tersebut ke salah satu dari tiga *worker* (Elendil, Isildur, atau Anarion) di belakangnya. Algoritma **Round Robin** (standar Nginx) akan memastikan beban didistribusikan secara bergantian ke setiap *worker*.

### **🛠️ Cara Mengerjakan**
Seluruh konfigurasi untuk soal ini hanya dilakukan di node **Elros**.
1.  **Install Nginx**: Paket `nginx` diinstall pada node **Elros**.
2.  **Buat Konfigurasi**: File konfigurasi baru dibuat di `/etc/nginx/sites-available/elros.K55.com`.
3.  **Definisikan Upstream**: Di dalam file tersebut, sebuah blok `upstream kesatria_numenor` dibuat. Blok ini berisi daftar alamat IP dan port dari ketiga *worker* Laravel (Elendil, Isildur, dan Anarion).
4.  **Konfigurasi Server Block**: Di file yang sama, sebuah `server` block dibuat yang `listen 80` dan merespon `server_name elros.K55.com`.
5.  **Atur Proxy Pass**: `location /` utama dikonfigurasi dengan `proxy_pass http://kesatria_numenor;`. Ini adalah perintah yang memberitahu Nginx untuk meneruskan semua permintaan ke grup *upstream* yang telah didefinisikan.
6.  **Atur Headers**: Perintah `proxy_set_header` ditambahkan untuk memastikan informasi klien (seperti IP asli) tetap diteruskan ke *worker*.
7.  **Aktifkan Situs**: Konfigurasi baru diaktifkan dengan membuat *symlink* ke `sites-enabled` dan menghapus konfigurasi *default*.
8.  **Restart Nginx**: *Service* `nginx` di Elros di-restart untuk menerapkan perubahan.

![Konfigurasi Load Balancer di Elros](assets/10_load_balance_elros.png)

### **✅ Cara Melakukan Validasi**
1.  **Validasi Klien (Miriel)**:
    * Dari node klien (Miriel), jalankan perintah `curl http://elros.K55.com/api/airing` beberapa kali.
    * **Hasil**: Perintah ini **berhasil** dan mengembalikan data JSON. Ini membuktikan bahwa *load balancer* Elros berfungsi, menerima permintaan, dan berhasil meneruskannya ke *worker* yang sehat.

    ![Validasi curl ke Elros (Load Balancer)](assets/10_curl_api_airing_4_kali.png)

2.  **Pemeriksaan Log Worker (Troubleshooting)**:
    * **Masalah Awal**: Saat memvalidasi, `tail /var/log/nginx/access.log` di **Elendil** menunjukkan error `500 Internal Server Error`. Ini menandakan *worker* Elendil gagal di-setup dengan benar.
    * **Perbaikan**: Masalah ini diatasi dengan menjalankan ulang skrip perbaikan Soal 7 di Elendil (terutama `composer update` dan `php artisan key:generate`).

3.  **Validasi Akhir (Pasca Perbaikan)**:
    * Tes `curl http://elendil.K55.com:8001/api/airing` (langsung ke Elendil) kini **berhasil** mengembalikan JSON.
    * Tes `tail /var/log/nginx/access.log` di Elendil, Isildur, dan Anarion setelah diakses menunjukkan log baru dengan status `200 OK`. Ini membuktikan bahwa ketiga *worker* sudah sehat dan *load balancer* Elros berfungsi penuh.

    | Log Elendil (Awalnya Error 500) | Log Isildur (Sehat) | Log Anarion (Sehat) |
    | :---: | :---: | :---: |
    | ![Log Elendil Awal](assets/10_validasi_round_robin_di_elendil.png) | ![Log Isildur](assets/10_validasi_round_robin_di_isildur.png) | ![Log Anarion](assets/10_validasi_round_robin_di_anarion.png) |

# 🚀 Laporan Praktikum Modul 3 - Jaringan Komputer (K55)

Dokumen ini dibuat untuk memandu anggota kelompok dalam memahami alur pengerjaan, konsep setiap soal, dan cara melakukan validasi.

---

## 📦 Soal 11: Load Testing & Tuning (Elros)

> **Catatan:** Langkah-langkah pada soal ini belum dieksekusi atau divalidasi.

### **Soal 11: Penyampaian Ulang**
> Musuh mencoba menguji kekuatan pertahanan Númenor. Dari node client, luncurkan serangan benchmark (`ab`) ke `elros.K55.com/api/airing/`:
> * Serangan Awal: `-n 100 -c 10` (100 permintaan, 10 bersamaan).
> * Serangan Penuh: `-n 2000 -c 100` (2000 permintaan, 100 bersamaan).
> Pantau kondisi para *worker* dan periksa log Elros untuk melihat apakah ada *worker* yang kewalahan atau koneksi yang gagal.
> Strategi Bertahan: Tambahkan `weight` dalam algoritma, kemudian catat apakah lebih baik atau tidak.

### **🎯 Maksud dari Soal No. 11**
Tujuan dari soal ini adalah untuk melakukan **Load Testing** (uji beban) dan **Tuning** (penyetelan) pada *load balancer* kita (Elros).
1.   **Load Testing**: Kita akan menggunakan *tool* `ab` (Apache Benchmark) untuk mensimulasikan banyak klien yang mengakses Elros secara bersamaan. Tujuannya adalah untuk melihat seberapa baik sistem kita (Elros + 3 *worker*) menangani stres/beban tersebut.
2.   **Monitoring**: Sambil tes berjalan, kita akan memantau penggunaan CPU di **Elendil, Isildur, dan Anarion** menggunakan `htop` untuk melihat bagaimana Elros membagi beban. Kita juga akan memeriksa log error di Elros jika ada permintaan yang gagal.
3.  **Tuning (Strategi Bertahan)**: Setelah melihat hasil tes awal (Round Robin), kita akan memodifikasi algoritma *load balancing* di Elros.  Sesuai modul *Reverse Proxy* , kita akan menambahkan `weight` (beban). Tujuannya adalah untuk melihat bagaimana perubahan strategi ini mempengaruhi kinerja (apakah jumlah permintaan yang gagal berkurang atau tidak).

### **🛠️ Cara Mengerjakan**
1.   **Persiapan Klien (Miriel)**: Install `apache2-utils` (yang berisi *tool* `ab`) dan `htop` (untuk monitoring). 
2.   **Persiapan Worker (Elendil, Isildur, Anarion)**: Install `htop` di ketiga *worker* agar kita bisa memantau CPU mereka.
3.  **Jalankan Tes 1 (Serangan Awal)**:
    * Buka 4 jendela terminal: 1 untuk Miriel, 1 untuk Elendil, 1 untuk Isildur, 1 untuk Anarion.
    * Di 3 *worker*, jalankan `htop`.
    * Di **Miriel**, jalankan perintah `ab -n 100 -c 10 http://elros.K55.com/api/airing/`.
    * Amati `htop` di 3 *worker* untuk melihat beban terdistribusi (seharusnya merata).
4.  **Jalankan Tes 2 (Serangan Penuh - Round Robin)**:
    * Masih dengan `htop` berjalan di *worker*.
    * Di **Miriel**, jalankan perintah `ab -n 2000 -c 100 http://elros.K55.com/api/airing/`.
    * Amati `htop` lagi dan catat jumlah `Failed requests` di output `ab`.
5.  **Terapkan Strategi Bertahan (Weight)**:
    * Di **Elros**, edit file konfigurasi Nginx (`/etc/nginx/sites-available/elros.K55.com`).
    *  Ubah blok `upstream` untuk menambahkan `weight` ke *server* (misal: `server 10.91.1.2:8001 weight=3;`). 
    * Restart `nginx` di Elros.
6.  **Jalankan Tes 3 (Uji Coba Weight)**:
    * Jalankan lagi "Serangan Penuh" (`ab -n 2000 -c 100 ...`) di **Miriel**.
    * Amati `htop` dan bandingkan jumlah `Failed requests` dengan Tes 2.

### **✅ Cara Melakukan Validasi**
1.  **Validasi Round Robin**: Selama Tes 2, `htop` di ketiga *worker* (Elendil, Isildur, Anarion) akan menunjukkan lonjakan penggunaan CPU yang relatif seimbang.
2.  **Validasi Weight**: Selama Tes 3, `htop` akan menunjukkan penggunaan CPU yang **tidak seimbang**. *Worker* yang diberi `weight=3` akan menunjukkan CPU *load* yang jauh lebih tinggi daripada *worker* dengan `weight=1`. Ini membuktikan strategi *weight* berfungsi.
3.  **Analisis Performa**: Bandingkan jumlah `Failed requests` dari output `ab` Tes 2 dengan Tes 3. Jika jumlah *fail* berkurang, maka strategi `weight` dianggap "lebih baik".
4.  **Analisis Log**: Periksa file `/var/log/nginx/error.log` di **Elros**.  Jika ada banyak *Failed requests*, log ini akan menunjukkan penyebabnya (misal, `worker_connections are not enough` atau `connect() failed`).