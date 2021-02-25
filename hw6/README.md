Apache помимо Nginx пока не собрался что-то, взял htop.


- загрузка SRPM пакета
```bash
[root@localhost ~]# wget https://mirror.netsite.dk/epel/7/SRPMS/Packages/h/htop-2.2.0-3.el7.src.rpm
--2021-02-24 11:32:55--  https://mirror.netsite.dk/epel/7/SRPMS/Packages/h/htop-2.2.0-3.el7.src.rpm
Resolving mirror.netsite.dk (mirror.netsite.dk)... 185.224.16.132
Connecting to mirror.netsite.dk (mirror.netsite.dk)|185.224.16.132|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 320616 (313K) [application/x-redhat-package-manager]
Saving to: ‘htop-2.2.0-3.el7.src.rpm’

100%[=============================================================================================>] 320,616      386KB/s   in 0.8s

2021-02-24 11:32:57 (386 KB/s) - ‘htop-2.2.0-3.el7.src.rpm’ saved [320616/320616]

[root@localhost ~]#
```

- создание древа каталогов
```bash
[root@localhost ~]# rpm -i htop-2.2.0-3.el7.src.rpm
warning: htop-2.2.0-3.el7.src.rpm: Header V3 RSA/SHA256 Signature, key ID 352c64e5: NOKEY
[root@localhost ~]#
```

- проверка/установка зависимостей
```bash
[root@localhost ~]# yum-builddep rpmbuild/SPECS/htop.spec
Loaded plugins: fastestmirror
Enabling base-source repository
```

- сборка пакета 
```bash
[root@localhost ~]# rpmbuild -bb rpmbuild/SPECS/htop.spec
Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.JTRuQ6
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd /root/rpmbuild/BUILD
+ rm -rf htop-2.2.0
+ /usr/bin/gzip -dc /root/rpmbuild/SOURCES/htop-2.2.0.tar.gz
+ /usr/bin/tar -xf -
+ STATUS=0
...
Wrote: /root/rpmbuild/RPMS/x86_64/htop-2.2.0-3.el7.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/htop-debuginfo-2.2.0-3.el7.x86_64.rpm
Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.mnzPug
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd htop-2.2.0
+ /usr/bin/rm -rf /root/rpmbuild/BUILDROOT/htop-2.2.0-3.el7.x86_64
+ exit 0
```

- проверка создавшихся пакетов
```bash
[root@localhost ~]#  ll rpmbuild/RPMS/x86_64/
total 344
-rw-r--r--. 1 root root 104376 Feb 24 11:35 htop-2.2.0-3.el7.x86_64.rpm
-rw-r--r--. 1 root root 244140 Feb 24 11:35 htop-debuginfo-2.2.0-3.el7.x86_64.rpm
```

- установка 
```bash
[root@localhost ~]# yum localinstall -y rpmbuild/RPMS/x86_64/htop-2.2.0-3.el7.x86_64.rpm
...
Installed:
  htop.x86_64 0:2.2.0-3.el7
  
Complete!
```

Htop заработал.


#### Создание удаленного репозитория.


- создание директории  
```bash
[root@centos-2gb-hel1-1 ~]# mkdir /usr/share/nginx/html/repo
```

- ранее собранный пакет помещен в директорию
```bash
[root@centos-2gb-hel1-1 ~]# ll /usr/share/nginx/html/repo/
total 108
-rw-r--r--. 1 root root 104376 Feb 24 17:35 htop-2.2.0-3.el7.x86_64.rpm
drwxr-xr-x. 2 root root   4096 Feb 24 18:21 repodata
[root@centos-2gb-hel1-1 ~]#
```


- создание репозитория 
```bash
[root@centos-2gb-hel1-1 ~]# createrepo /usr/share/nginx/html/repo/
Spawning worker 0 with 1 pkgs
Workers Finished
Saving Primary metadata
Saving file lists metadata
Saving other metadata
Generating sqlite DBs
Sqlite DBs complete
```

- проверка репозитория
```bash
[root@localhost ~]# yum repolist enabled | grep otus
otus                  otus-linux                                               1
```
```bash
[root@localhost ~]# curl -a http://95.216.149.195/repo/
<html>
<head><title>Index of /repo/</title></head>
<body>
<h1>Index of /repo/</h1><hr><pre><a href="../">../</a>
<a href="repodata/">repodata/</a>                                          24-Feb-2021 17:21                   -
<a href="htop-2.2.0-3.el7.x86_64.rpm">htop-2.2.0-3.el7.x86_64.rpm</a>                        24-Feb-2021 16:35              104376
</pre><hr></body>
</html>
[root@localhost ~]#
```

-установка собранного пакета на локальном сервере из удаленного репоитория 
```bash
[root@localhost ~]# yum install htop
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
Resolving Dependencies
--> Running transaction check
---> Package htop.x86_64 0:2.2.0-3.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

=======================================================================================================================================
 Package                      Arch                           Version                                Repository                    Size
=======================================================================================================================================
Installing:
 htop                         x86_64                         2.2.0-3.el7                            otus                         102 k

Transaction Summary
=======================================================================================================================================
Install  1 Package

Total download size: 102 k
Installed size: 217 k
Is this ok [y/d/N]: y
Downloading packages:
htop-2.2.0-3.el7.x86_64.rpm                                                                                     | 102 kB  00:00:00
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : htop-2.2.0-3.el7.x86_64                                                                                             1/1
  Verifying  : htop-2.2.0-3.el7.x86_64                                                                                             1/1

Installed:
  htop.x86_64 0:2.2.0-3.el7

Complete!
```

- проверка репозитория из которого установлен пакет
```bash
[root@localhost ~]# find-repos-of-install htop
Loaded plugins: fastestmirror
htop-2.2.0-3.el7.x86_64 from repo otus
[root@localhost ~]#
```


Ссылка на репозиториий http://95.216.149.195/repo/
