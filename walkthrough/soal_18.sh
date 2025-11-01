# ==== Palantir, Narvi ====
apt update
apt install mariadb-server -y

# ==== Palantir ====
# [mysqld]
# server-id=1
# log_bin=mysql-bin
# bind-address=0.0.0.0

service mariadb restart

mysql -u root <<EOF
CREATE USER 'palantir'@'%' IDENTIFIED BY 'palantir123';
GRANT REPLICATION SLAVE ON *.* TO 'palantir'@'%';
FLUSH PRIVILEGES;

FLUSH TABLES WITH READ LOCK;
SHOW MASTER STATUS;
EOF

# ==== Narvi ====
# [mysqld]
# server-id=2
# relay-log=relay-bin

service mariadb restart

mysql -u root <<EOF
CHANGE MASTER TO
  MASTER_HOST='palantir.k55.com',
  MASTER_USER='palantir',
  MASTER_PASSWORD='palantir123',
  MASTER_LOG_FILE='mysql-bin.000001',
  MASTER_LOG_POS=120;

START SLAVE;

SHOW SLAVE STATUS\G
EOF

# TESTING (Palantir)
mysql -u root <<EOF
CREATE DATABASE jarkom;
USE jarkom;
CREATE TABLE test (id INT PRIMARY KEY, name VARCHAR(50));
INSERT INTO test (id, name) VALUES (1, 'Jarkom');
EOF

# TESTING (Narvi)
mysql -u root <<EOF
USE jarkom;
SELECT * FROM test;
EOF
