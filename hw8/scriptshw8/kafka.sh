#!/bin/bash
yum -y install java-1.8.0-openjdk
useradd kafka -m
cd /home/kafka
curl -o kafka.tgz https://mirrors.estointernet.in/apache/kafka/2.7.0/kafka_2.13-2.7.0.tgz
mkdir kafka/
tar -C /home/kafka/kafka -xvzf kafka.tgz --strip-components 1
touch /home/kafka/kafka/kafka.log
chown -R kafka:kafka /home/kafka/kafka

cat << EOF | sudo tee /etc/systemd/system/zookeeper.service
[Unit] 
Requires=network.target remote-fs.target
After=network.target remote-fs.target
[Service] 
Type=simple
User=kafka
ExecStart=/home/kafka/kafka/bin/zookeeper-server-start.sh /home/kafka/kafka/config/zookeeper.properties
ExecStop=/home/kafka/kafka/bin/zookeeper-server-stop.sh
Restart=on-abnormal
[Install] 
WantedBy=multi-user.target
EOF

cat << EOF | sudo tee /etc/systemd/system/kafka.service
[Unit] 
Requires=zookeeper.service
After=zookeeper.service
[Service] 
Type=simple
User=kafka
ExecStart=/bin/sh -c '/home/kafka/kafka/bin/kafka-server-start.sh /home/kafka/kafka/config/server.properties > /home/kafka/kafka/kafka.log 2>&1'
ExecStop=/home/kafka/kafka/bin/kafka-server-stop.sh
Restart=on-abnormal
CPUShares=1500
MemoryLimit=3G
LimitCORE=infinity
LimitNOFILE=65536
[Install] 
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start kafka
systemctl enable kafka
systemctl status kafka | awk "/\Active/ {print}"



































