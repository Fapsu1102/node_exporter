#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Vui lòng chạy script này với quyền root!"
  exit 1
fi

# Bước 1: Tạo người dùng hệ thống node_exporter
echo "Tạo người dùng hệ thống node_exporter..."
useradd --system --no-create-home --shell /bin/false node_exporter

# Bước 2: Tải xuống Node Exporter
echo "Tải xuống Node Exporter..."
wget -q https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz

# Bước 3: Giải nén Node Exporter
echo "Giải nén Node Exporter..."
tar -xzf node_exporter-1.8.2.linux-amd64.tar.gz
cd node_exporter-1.8.2.linux-amd64

# Bước 4: Di chuyển và thiết lập quyền cho Node Exporter
echo "Di chuyển và thiết lập quyền..."
cp node_exporter /usr/local/bin
chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Bước 5: Tạo tệp dịch vụ Systemd
echo "Tạo tệp dịch vụ Systemd cho Node Exporter..."
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Bước 6: Khởi động và kích hoạt dịch vụ Node Exporter
echo "Tải lại Systemd và khởi động Node Exporter..."
systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

# Bước 7: Kiểm tra trạng thái Node Exporter
echo "Kiểm tra trạng thái dịch vụ Node Exporter..."
systemctl status node_exporter --no-pager

# Dọn dẹp
cd ..
rm -rf node_exporter-1.8.2.linux-amd64 node_exporter-1.8.2.linux-amd64.tar.gz

echo "Cài đặt Node Exporter hoàn tất!"
