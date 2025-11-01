# ==== Galadriel, Celeborn, Oropher ====
apt update
apt install nginx php php8.4-fpm -y


rm -rf /var/www/html/*
echo "<?php echo 'Galadriel'; ?>" > /var/www/html/index.php
echo "<?php echo 'Celeborn'; ?>" > /var/www/html/index.php
echo "<?php echo 'Oropher'; ?>" > /var/www/html/index.php