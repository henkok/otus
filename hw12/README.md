### Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников
- установка необходимых пакетов
```bash
[root@localhost ~]# yum install -y epel-release
[root@localhost ~]# yum install -y pam_script
```

- создание группы admin 
```bash
[root@localhost ~]# groupadd admin
```
- создание пользователей и помещение одного в группу admin
```bash
[root@localhost ~]# useradd test -s /bin/bash
[root@localhost ~]# useradd test_week -s /bin/bash
[root@localhost ~]# usermod -aG admin test
```
- установка пароля для пользователя 
```bash
[root@localhost ~]# echo "test:123456" | chpasswd
[root@localhost ~]# echo "test_week:123456" | chpasswd
```
- проверка возможности входа по паролю
```bash
[root@localhost ~]# sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
```
- подключение модуля PAM 
```bash
[root@localhost ~]# sed -i "2i auth  required  pam_script.so"  /etc/pam.d/sshd
```
- перезагрузка SSH 
```bash
[root@localhost ~]# systemctl restart sshd
```
- проверка используемых файлов 
```bash
[root@localhost ~]# rpm -ql pam_script
/etc/pam-script.d
/etc/pam_script
/etc/pam_script_acct
/etc/pam_script_auth
/etc/pam_script_passwd
/etc/pam_script_ses_close
/etc/pam_script_ses_open
/lib64/security/pam_script.so
/usr/share/doc/pam_script-1.1.8
/usr/share/doc/pam_script-1.1.8/AUTHORS
/usr/share/doc/pam_script-1.1.8/COPYING
/usr/share/doc/pam_script-1.1.8/ChangeLog
/usr/share/doc/pam_script-1.1.8/NEWS
/usr/share/doc/pam_script-1.1.8/README
/usr/share/doc/pam_script-1.1.8/README.pam_script
/usr/share/man/man7/pam-script.7.gz
[root@localhost ~]#
```
- редактирование файла /etc/pam_script
```bash
#!/bin/bash

if groups $PAM_USER | grep admin > /dev/null
then
	exit 0
fi
if [[ `date +%u` > 5 ]]
then
	exit 1
fi
```
В скрипте происходит проверка группы пользователя. Если admin пускать всегда, если группа отлична - проверяется день

- установка даты для выходного дня 
```bash
[root@localhost ~]# date 04031700
Sat Apr  3 17:00:00 EDT 2021
```

- проверка: пользовать test_week не должен зайти, а пользователь test должен
```bash
[root@localhost ~]# ssh test_week@localhost
The authenticity of host 'localhost (::1)' can't be established.
ECDSA key fingerprint is SHA256:Re8cKVgD6B7nxWftBzC1IywqxUr0wewTdgWNHyNaHps.
ECDSA key fingerprint is MD5:a4:84:f3:36:fd:40:56:35:36:96:81:6b:47:77:81:33.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'localhost' (ECDSA) to the list of known hosts.
test_week@localhost's password: 
Permission denied, please try again.
[root@localhost ~]# ssh test@localhost
test@localhost's password: 
[test@hw16 ~]$ 
```

### дать конкретному пользователю права работать с докером и возможность рестартить докер сервис
- установка docker
```
[root@localhost ~]# curl -fsSL https://get.docker.com/ | sh
```
- права для пользователя test на работу с docker путем помещения его в группу docker
```bash
[root@localhost ~]# usermod -aG docker test
```
- наделение пользователя test правами управлять сервисами
```bash
[root@localhost ~]# vi /etc/polkit-1/rules.d/01-systemd.rules
```

```bash
polkit.addRule(function(action, subject) {
 if (action.id.match("org.freedesktop.systemd1.manage-units") &&
subject.user === "test") {
 return polkit.Result.YES;
 }
});
```
- проверка прав 
```bash
[test@localhost ~]$ systemctl stop docker
Warning: Stopping docker.service, but it can still be activated by:
  docker.socket
[test@localhost ~]$ systemctl status docker
● docker.service - Docker Application Container Engine
   Loaded: loaded (/usr/lib/systemd/system/docker.service; disabled; vendor preset: disabled)
   Active: inactive (dead) since Sat 2021-04-03 17:24:14 EDT; 13s ago
     Docs: https://docs.docker.com
  Process: 2279 ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock (code=exited, status=0/SUCCESS)
 Main PID: 2279 (code=exited, status=0/SUCCESS)
[test@localhost ~]$ systemctl start docker
[test@localhost ~]$ systemctl status docker
● docker.service - Docker Application Container Engine
   Loaded: loaded (/usr/lib/systemd/system/docker.service; disabled; vendor preset: disabled)
   Active: active (running) since Sat 2021-04-03 17:24:33 EDT; 5min ago
     Docs: https://docs.docker.com
 Main PID: 2456 (dockerd)
    Tasks: 7
   Memory: 46.1M
   CGroup: /system.slice/docker.service
           └─2456 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
[test@localhost ~]$
```

```bash
[test@hw16 ~]$ docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
b8dfde127a29: Pull complete 
Digest: sha256:308866a43596e83578c7dfa15e27a73011bdd402185a84c5cd7f32a88b501a24
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.
```


