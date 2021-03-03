#!/bin/bash
cat << EOF | sudo tee /usr/bin/logalert.sh
#!/bin/bash
awk "/\$keyword/ {print}" \$logfile
EOF

cat << EOF | sudo tee /etc/sysconfig/logalert
keyword="WARNING"
logfile="/var/log/tuned/tuned.log"
EOF

# Unit-файл для сервиса logalert.service:
cat << EOF | sudo tee /etc/systemd/system/logalert.service
[Unit]
Description=Readind log
After=network.target

[Service]
EnvironmentFile=-/etc/sysconfig/logalert
ExecStart=/bin/bash /usr/bin/logalert.sh
Type=simple

[Install]
WantedBy=multi-user.target
EOF

# Unit-файл для таймера logalert.timer:
cat << EOF | sudo tee /etc/systemd/system/logalert.timer
[Unit]
Description=Run every 30 seconds

[Timer]
OnBootSec=1m
OnUnitActiveSec=30s
Unit=logalert.service

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable logalert.service
systemctl enable logalert.timer
systemctl start logalert.timer
