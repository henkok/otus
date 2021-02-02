#!/usr/bin/env bash
mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
#устанавливаем утилиты
yum install -y mdadm smartmontools hdparm gdisk
#нулим суперблоки
mdadm --zero-superblock --force /dev/sd{b,c,d,e}
#создаем рейд5 из 4 дисков
mdadm --create --verbose --force /dev/md0 -l 5 -n 4 /dev/sd{b,c,d,e}
#проверяем сборку рейда
cat /proc/mdstat
#создаем каталог для конфигурационного файла
mkdir /etc/mdadm/
#создаем файл и заполняем его
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
#делаем gpt разметку на raid
parted -s /dev/md0 mklabel gpt
#создаем партиции
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%
#создаем на них файловую систему
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
#монтируем в каталоги
mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done
#автоматически монтируем Фс при загрузке
echo "#NEW DEVICE" >> /etc/fstab
for i in $(seq 1 5); do echo `sudo blkid /dev/md0p$i | awk '{print $2}'` /u0$i ext4 defaults 0 0 >> /etc/fstab; done
