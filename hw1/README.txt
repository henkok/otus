Вложенный Vagrantfile с ml ядром, но на нем не получилось выполнить синхранизацию каталогов на virtualbox из-за virtualBox Guest Additions. Не смог с ними справиться.

#Собрал ядро 5.4.93

wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.4.93.tar.xz
tar -xvf linux-5.4.93.tar.xz -C /usr/src
cd /usr/src/linux-5.4.93/
yum groupinstall "Development Tools"
yum install ncurses-devel openssl-devel bc
cd /usr/src/linux-5.4.93/
make oldconfig
yum install elfutils-libelf-devel
make
make modules_install install

#Обновил GRUB
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-set-default 0


#Далее в виртуальной машине подключил образ с Guest Additions и смонтировал

mkdir /guest/VirtualBoxGuestAdditions
mount -r /dev/cdrom /guest/VirtualBoxGuestAdditions

#Понадобилась также указать переменную KERN_DIR

KERN_DIR=/usr/src/linux-5.4.93/`uname -r`
export KERN_DIR


#Далее установка 
cd /guest/VirtualBoxGuestAdditions
sudo ./VBoxLinuxAdditions.run

Но в итоге, получившийся vagrant box из этой виртуалки, оказался очень тяжелым 8+ Gb . С этим пока не разобрался 