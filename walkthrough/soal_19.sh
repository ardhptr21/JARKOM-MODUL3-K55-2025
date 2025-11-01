# ==== Pharazon, Elros ===

# Tambah dipaling atas config nginx nya
# limit_req_zone $binary_remote_addr zone=limit_zone:10m rate=10r/s;

# Pada bagian location /
# limit_req zone=limit_zone burst=20 nodelay;

# Testing 
ab -n 500 -c 50 http://pharazon.k55.com/
ab -n 500 -c 50 http://elros.k55.com/