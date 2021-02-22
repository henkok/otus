### 1. Попасть в систему без пароля несколькими способами

#### Способ 1. init=/bin/sh

- после добавления **init=/bin/sh и сtrl-x** система загружается с приветствием 
```bash
sh-4.2#
```

- монтирую корневую фс в режим read-write 
```bash
sh-4.2# mount -o remount,rw
```

- проверяю
```bash
h-4.2# mount | grep root
/dev/mapper/centos-root on /type xfs (rw,realtime,attr2,inode64,noquota)
```

#### Способ 2. rd.break

После добавления **rd.break и сtrl-x** система загружается в emergency mode
```bash
Entering emergency mode. Exit the shell to continue.
Type "jornalctl" to view system logs.
You might want to save "/run/initframfs/rdsosreport.txt" to USB stick or /boot after mounting them and attach it to a bug report.
switch_root:/#
```

- перемонтирую систему 
```bash
switch_root:/# mount -o remount,rw /sysroot
switch_root:/# chroot /sysroot
```

- меняю пароль 
```bash
sh-4.2# passwd root
Changing password for user root.
New password:
BAD PASSWORD: The password is shorter than 8 characters
Retype new password:
passwd: all authentication token updated successfully.
sh-4.2# touch /.autorelabel
```

- перезагрузка
```bash
root@192.168.145.141's password:
Last login: Mon Feb 22 04:33:32 2021
[root@localhost ~]#
```

#### Способ 3. rw init=/sysroot/bin/sh

- в строке linux16 меняю ro на rw init=/sysroot/bin/sh
```bash
Entering emergency mode. Exit the shell to continue.
Type "jornalctl" to view system logs.
You might want to save "/run/initframfs/rdsosreport.txt" to USB stick or /boot after mounting them and attach it to a bug report.
:/#
```
*Остальные шаги повторяются из второго способа*

### 2. На системе с LVM переименовываем VG

- текущее состояние системы
```bash
[root@localhost ~]# lsblk
NAME               MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                  8:0    0   20G  0 disk
├─sda1               8:1    0  300M  0 part /boot
└─sda2               8:2    0 13.5G  0 part
  ├─centos-root 253:0    0    3G  0 lvm  /
  ├─centos-swap 253:1    0  496M  0 lvm  [SWAP]
  ├─centos-var  253:2    0    5G  0 lvm  /var
  └─centos-home 253:3    0    5G  0 lvm  /home
sr0                 11:0    1  4.5G  0 rom
[root@localhost ~]#
```

```bash
[root@localhost ~]# vgs
  VG     #PV #LV #SN Attr   VSize   VFree
  centos   1   4   0 wz--n- <13.48g    0
[root@localhost ~]#
```

- переименование
```bash
[root@localhost ~]# vgrename centos centoshw5
  Volume group "centos" successfully renamed to "centoshw5"
[root@localhost ~]#
[root@localhost ~]# vgs
  VG        #PV #LV #SN Attr   VSize   VFree
  centoshw5   1   4   0 wz--n- <13.48g    0
```

- заменяею в конфигах на новое название VG 
```bash
[root@localhost ~]#sed -i 's/centos/centoshw5/g' /etc/fstab
[root@localhost ~]#sed -i 's/centos/centoshw5/g' /boot/grub2/grub.cfg
```

- пересоздание initrd image 
```
[root@localhost ~]# mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
Executing: /usr/sbin/dracut -f -v /boot/initramfs-3.10.0-1127.el7.x86_64.img 3.10.0-1127.el7.x86_64
dracut module 'modsign' will not be installed, because command 'keyctl' could not be found!
dracut module 'busybox' will not be installed, because command 'busybox' could not be found!
dracut module 'crypt' will not be installed, because command 'cryptsetup' could not be found!
dracut module 'dmraid' will not be installed, because command 'dmraid' could not be found!
dracut module 'dmsquash-live-ntfs' will not be installed, because command 'ntfs-3g' could not be found!
dracut module 'mdraid' will not be installed, because command 'mdadm' could not be found!
dracut module 'multipath' will not be installed, because command 'multipath' could not be found!
dracut module 'cifs' will not be installed, because command 'mount.cifs' could not be found!
dracut module 'iscsi' will not be installed, because command 'iscsistart' could not be found!
dracut module 'iscsi' will not be installed, because command 'iscsi-iname' could not be found!
95nfs: Could not find any command of 'rpcbind portmap'!
...
*** Resolving executable dependencies done***
*** Hardlinking files ***
*** Hardlinking files done ***
*** Stripping files ***
*** Stripping files done ***
*** Generating early-microcode cpio image contents ***
*** Constructing AuthenticAMD.bin ****
*** No early-microcode cpio image needed ***
*** Store current command line parameters ***
*** Creating image file ***
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-1127.el7.x86_64.img' done ***
[root@localhost ~]#
```

- после рестарта проверка

```bash
root@192.168.145.141's password:
Last login: Mon Feb 22 04:53:48 2021 from 192.168.145.1
[root@localhost ~]# vgs
  VG        #PV #LV #SN Attr   VSize   VFree
  centoshw5   1   4   0 wz--n- <13.48g    0
[root@localhost ~]#
```

```bash
[root@localhost ~]# lsblk
NAME               MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                  8:0    0   20G  0 disk
├─sda1               8:1    0  300M  0 part /boot
└─sda2               8:2    0 13.5G  0 part
  ├─centoshw5-root 253:0    0    3G  0 lvm  /
  ├─centoshw5-swap 253:1    0  496M  0 lvm  [SWAP]
  ├─centoshw5-var  253:2    0    5G  0 lvm  /var
  └─centoshw5-home 253:3    0    5G  0 lvm  /home
sr0                 11:0    1  4.5G  0 rom
```

### 3. Добавить модуль в initrd

- содание каталога 
```bash
[root@localhost ~]# mkdir /usr/lib/dracut/modules.d/01test
[root@localhost ~]#
```

- поместил скрипты в созданный каталог 
```bash
[root@localhost modules.d]# cat /usr/lib/dracut/modules.d/01test/module-setup.sh
#!/bin/bash

check() {
    return 0
}

depends() {
    return 0
}

install() {
    inst_hook cleanup 00 "${moddir}/test.sh"
}
[root@localhost modules.d]#
[root@localhost modules.d]# cat /usr/lib/dracut/modules.d/01test/test.sh
#!/bin/bash

exec 0<>/dev/console 1<>/dev/console 2<>/dev/console
cat <<'msgend'
Hello! You are in dracut module!
 ___________________
< I'm dracut module >
 -------------------
   \
    \
        .--.
       |o_o |
       |:_/ |
      //   \ \
     (|     | )
    /'\_   _/`\
    \___)=(___/
msgend
sleep 10
echo " continuing...."
[root@localhost modules.d]#
```

- сборка initrd
```
[root@localhost modules.d]# dracut -f -v
Executing: /usr/sbin/dracut -f -v
dracut module 'modsign' will not be installed, because command 'keyctl' could not be found!
dracut module 'busybox' will not be installed, because command 'busybox' could not be found!
dracut module 'crypt' will not be installed, because command 'cryptsetup' could not be found!
...
*** Store current command line parameters ***
*** Creating image file ***
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-1127.el7.x86_64.img' done ***
```
- проверка модуля
```bash
[root@localhost modules.d]# lsinitrd -m /boot/initramfs-$(uname -r).img | grep test
test
[root@localhost modules.d]#
```bash

Скрин загрузки приложен