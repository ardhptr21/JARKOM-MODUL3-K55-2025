# ==== NODE CLIENT (Miriel) ====
apt update
apt install apache2-utils -y

ab -n 1000 -c 100 -A noldor:silvan http://pharazon.k55.com

# ==== Galadriel ====
service nginx stop