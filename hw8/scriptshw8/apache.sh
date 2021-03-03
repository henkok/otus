#!/bin/bash
yum install -y httpd
setenforce 0
cp /usr/lib/systemd/system/httpd.service /etc/systemd/system/httpd@.service
sed -i 's/ExecStart=\/usr\/sbin\/httpd \$OPTIONS/ExecStart=\/usr\/sbin\/httpd \$OPTIONS -f \/etc\/httpd\/conf\/\%i.conf/g' /etc/systemd/system/httpd@.service
# first
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/my.conf
sed -i 's/Listen\ 80/Listen\ 81/g' /etc/httpd/conf/my.conf
sed -i "33i PidFile \/run\/httpd\/my.pid" /etc/httpd/conf/my.conf
sed -i 's/\/var\/www\/html/\/var\/www\/html\/my/g' /etc/httpd/conf/my.conf
# second
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/my2.conf
sed -i 's/Listen\ 80/Listen\ 82/g' /etc/httpd/conf/my2.conf
sed -i "33i PidFile \/run\/httpd\/my2.pid" /etc/httpd/conf/my2.conf
sed -i 's/\/var\/www\/html/\/var\/www\/html\/my2/g' /etc/httpd/conf/my2.conf



mkdir /var/www/html/my
mkdir /var/www/html/my2

echo hello1 > /var/www/html/my/index.html
echo hello2 > /var/www/html/my2/index.html

systemctl daemon-reload
systemctl start httpd@my.service
systemctl start httpd@my2.service


echo STATUS
systemctl status httpd@my.service | awk "/\Active/ {print}"
systemctl status httpd@my2.service | awk "/\Active/ {print}"
echo TEST
curl 192.168.50.11:81 
curl 192.168.50.11:82
echo A-A-A-A-A-A-A-A

