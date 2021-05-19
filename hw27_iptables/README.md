** Vagrantfile из предыдущего занятия. Ненужные хосты отключены. **

## Сценарии iptables

1. реализовать knocking port
	- centralRouter может попасть на ssh inetrRouter через knock скрипт пример в материалах
2. добавить inetRouter2, который виден(маршрутизируется (host-only тип сети для виртуалки)) с хоста или форвардится порт через локалхост
	- запустить nginx на centralServer
	- пробросить 80й порт на inetRouter2 8080
	- дефолт в инет оставить через inetRouter
	- реализовать проход на 80й порт без маскарадинга


## 1. Knocking port
На centralRouter необходимо:
- выполнить скрипт `sudo /vagrant/portknock.sh 192.168.255.1 8881 7777 9991` 
- покдлючиться `ssh vagrant@192.168.255.1` пароль - vagrant (аутентицикация по паролю включена)
```
[vagrant@centralRouter ~]$ ssh vagrant@192.168.255.1
The authenticity of host '192.168.255.1 (192.168.255.1)' can't be established.
ECDSA key fingerprint is SHA256:q3mQtsc1ZVxcQqxhfmCvz7E0rZqOzXGp28aRg3vbXsQ.
ECDSA key fingerprint is MD5:ef:09:d9:9e:74:88:d7:5d:0f:03:ee:c0:13:39:32:fd.
Are you sure you want to continue connecting (yes/no)? yes 
Warning: Permanently added '192.168.255.1' (ECDSA) to the list of known hosts.
vagrant@192.168.255.1's password: 
[vagrant@inetRouter ~]$
```


## 2. Проброс порта

На роутере inetRouter2 поднимается интерфейс, доступный с хоста - ip 10.1.2.10.
При обращении к этому IP с портом 8080, происходит перенаправление на ip 192.168.0.2 nginx 

```
linux@linux-PC:~/Desktop/hw27$ curl 10.1.2.10:8080
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <title>Welcome to CentOS</title>
  <style rel="stylesheet" type="text/css"> 
....
</body>
</html>
linux@linux-PC:~/Desktop/hw27$
```
```
[vagrant@inetRouter2 ~]$ traceroute 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  gateway (192.168.255.14)  0.437 ms  0.372 ms  0.248 ms
 2  192.168.255.1 (192.168.255.1)  1.094 ms  1.079 ms  1.023 ms
 3  * * *
 4  *^C
[vagrant@inetRouter2 ~]$ 
```
```
[vagrant@inetRouter2 ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=59 time=40.5 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=59 time=40.4 ms
^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1004ms
rtt min/avg/max/mdev = 40.471/40.507/40.544/0.204 ms
[vagrant@inetRouter2 ~]$ 
```