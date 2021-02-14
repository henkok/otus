### 1. Определить алгоритм с наилучшим сжатием
###### - определить какие алгоритмы сжатия поддерживает zfs
LZ4, gzip (1-9), LZJB и ZLE
###### - создать 4 файловых системы на каждой применить свой алгоритм сжатия
```html
[root@lvm ~]# zpool create -f pool1 /dev/sdb
[root@lvm ~]# zpool list
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
pool1  4.50G  94.5K  4.50G        -         -     0%     0%  1.00x    ONLINE  -
```
###### - создать 4 файловых системы на каждой применить свой алгоритм сжатия
```html
[root@lvm ~]# zfs create pool1/datalz4
[root@lvm ~]# zfs create pool1/datagzip
[root@lvm ~]# zfs create pool1/datalzjb
[root@lvm ~]# zfs create pool1/datazle
```
###### - сжатие
```html
[root@lvm ~]# zfs set compression=lz4 pool1/datalz4
[root@lvm ~]# zfs set compression=gzip-9 pool1/datagzip
[root@lvm ~]# zfs set compression=lzjb pool1/datalzjb
[root@lvm ~]# zfs set compression=zle pool1/datazle
```
###### - скачать файл “Война и мир” и расположить на файловой системе
```html
[root@lvm datagzip]# du -h war.txt 
1.2M	war.txt
[root@lvm datalz4]# du -h war.txt 
2.0M	war.txt
[root@lvm datalzjb]# du -h war.txt 
2.4M	war.txt
[root@lvm datazle]# du -h war.txt 
512	war.txt
```
Самое эффективное сжатие получилось при использовании zle 


### 2. Определить настройки pool’a
###### - С помощью команды zfs import собрать pool ZFS.
```html
[root@lvm importpool]# zpool import -d ${PWD}/zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

	otus                                    ONLINE
	  mirror-0                              ONLINE
	    /root/importpool/zpoolexport/filea  ONLINE
	    /root/importpool/zpoolexport/fileb  ONLINE
[root@lvm importpool]# zpool import -d ${PWD}/zpoolexport/ otus
[root@lvm importpool]# zpool list
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
otus    480M  2.18M   478M        -         -     0%     0%  1.00x    ONLINE  -
pool1  4.50G  11.3M  4.49G        -         -     0%     0%  1.00x    ONLINE  -
```
#### Командами zfs определить настройки
###### - размер хранилища
```html
[root@lvm importpool]# zpool iostat otus
              capacity     operations     bandwidth 
pool        alloc   free   read  write   read  write
----------  -----  -----  -----  -----  -----  -----
otus        2.09M   478M      0      2  4.64K  13.2K
```
###### - тип pool
```html
[root@lvm importpool]# zpool status otus
  pool: otus
 state: ONLINE
  scan: none requested
config:

	NAME                                    STATE     READ WRITE CKSUM
	otus                                    ONLINE       0     0     0
	  mirror-0                              ONLINE       0     0     0
	    /root/importpool/zpoolexport/filea  ONLINE       0     0     0
	    /root/importpool/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors
```
ответ - mirror-0


###### - значение recordsize
```html
[root@lvm importpool]# zfs get recordsize otus
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local
```
###### - какое сжатие используется
```html
[root@lvm importpool]# zfs get compression otus
NAME  PROPERTY     VALUE     SOURCE
otus  compression  zle       local
```
###### - какая контрольная сумма используется
```html
[root@lvm importpool]# zfs get checksum otus
NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     local
```

### 3. Найти сообщение от преподавателей
###### - Восстановить файл локально
```html
[root@lvm snap]# zfs recv otus/storage@task2 < otus_task2.file 
[root@lvm snap]# zfs get mountpoint otus
NAME  PROPERTY    VALUE       SOURCE
otus  mountpoint  /otus       default
```
###### - Найти зашифрованное сообщение в файле secret_message
```html
[root@lvm snap]# find /otus -type f -name secret_message
/otus/storage/task1/file_mess/secret_message
[root@lvm snap]# cat /otus/storage/task1/file_mess/secret_message
https://github.com/sindresorhus/awesome 
```
Ссылка - https://github.com/sindresorhus/awesome












