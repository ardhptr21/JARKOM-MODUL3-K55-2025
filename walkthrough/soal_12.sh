# ==== Galadriel, Celeborn, Oropher ====
apt update
apt install nginx php php8.4-fpm -y

rm -rf /var/www/html/*
cat <<EOF > /var/www/html/index.php
<?php
echo "Hostname: " . gethostname() . "\n";
?>
EOF

service nginx start
service php8.4-fpm start