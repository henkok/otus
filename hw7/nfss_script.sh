#!/bin/bash
# установка и запуск
sudo yum install -y nfs-utils
sudo systemctl start rpcbind
sudo systemctl start nfs-server
sudo systemctl start rpc-statd 
sudo systemctl start nfs-idmapd
sudo systemctl enable rpcbind
sudo systemctl enable nfs-server
sudo systemctl enable rpc-statd 
sudo systemctl enable nfs-idmapd
# создание директории
sudo mkdir /upload
sudo chmod -R 777 /upload/
touch /upload/hello_from_server
# описание в конфиге
cat << EOF | sudo tee /etc/exports
/upload 192.168.50.11(async,rw,nocrossmnt,wdelay,hide,secure,sec=sys,no_subtree_check,root_squash,no_all_squash,secure_locks,no_pnfs,anonuid=5555,anongid=5555,root_squash,no_all_squash)
EOF

# примененние конфигов
sudo exportfs -ra
# настройка файрвола
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --permanent --add-service=mountd
sudo firewall-cmd --permanent --add-service=nfs3
sudo firewall-cmd --permanent --add-service=rpc-bind
sudo firewall-cmd --reload

