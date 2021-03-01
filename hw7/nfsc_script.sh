#!/bin/bash
# установка
sudo yum install -y nfs-utils
sudo systemctl start firewalld
sudo systemctl enable firewalld
# создание и монтирование директории
sudo mkdir /upload/
sudo mount.nfs -vv 192.168.50.10:/upload /upload -o nfsvers=3,proto=udp,hard
# 
touch /upload/hello_from_client
# настройка автомонтирования
cat << EOF | sudo tee /etc/systemd/system/upload.mount
[Unit]
Description = Mount NFS Share
Requires=network-online.service
After=network-online.service

[Mount]
What=192.168.50.10:/upload
Where=/upload
Type=nfs
Options=defaults

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl start upload.mount
sudo systemctl enable upload.mount
  













