**Задание**

1. Между двумя виртуалками поднять vpn в режимах
- tun
- tap
Прочувствовать разницу.

2. Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на виртуалку

***Сеть***

![alt text](./hw_31.png)

***Запуск стенда***
1. При запуске `vagrant up` стенд поднимается в конфигурации site-to-site (sts.yml) в режиме `tap`. 
2. При изменении значения переменной `stsdev` на `'tun'` в конфигах `./inventories/host_vars/server.yml` и в `./inventories/host_vars/client.yml` и выполнении playbook `sts.yml` - режим изменится tun.
3. Для запуска стенда в режиме remote-access необходимо выполнить playbook `remote.yml`, openvpn поднимется на нестандартном порту rasport: '2395'.





***Между двумя виртуалками поднять vpn в режимах***
***- tun***
***- tap***
***Прочувствовать разницу.***

1. Установка пакетов `openvpn`, `easy-rsa`, `iperf3` из `epel-репозиторий`:
```
[root@server ~]# yum install -y openvpn easy-rsa iperf3

[root@client ~]# yum install -y openvpn iperf3
```

2. IP-адрес на loopback-интерфейс:
```
[root@server ~]# cat > /etc/sysconfig/network-scripts/ifcfg-lo.2 <<EOF
DEVICE=lo:2
IPADDR=10.0.0.1
PREFIX=32
NETWORK=10.0.0.1
ONBOOT=yes
EOF

[root@client ~]# cat > /etc/sysconfig/network-scripts/ifcfg-lo.2 <<EOF
DEVICE=lo:2
IPADDR=10.0.0.2
PREFIX=32
NETWORK=10.0.0.2
ONBOOT=yes
EOF
```

3. Forwarding пакетов:
```
[root@server ~]# echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/ip_forwarding.conf && systemctl restart network
[root@client ~]# echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/ip_forwarding.conf && systemctl restart network
```


***Настройка сервера***

4. Генерация ключа:
```
[root@server ~]# openvpn --genkey --secret /etc/openvpn/static.key
```

5. Сonfig tap режима:
```
[root@server ~]# cat > /etc/openvpn/server.conf <<EOF
dev tap
ifconfig 172.16.10.1 255.255.255.0
topology subnet
route 10.0.0.2 255.255.255.255 172.16.10.2
secret /etc/openvpn/static.key
compress lzo
status /var/log/openvpn-status.log
log /var/log/openvpn.log
verb 3
EOF
```

6. Запуск:
```
[root@server ~]# systemctl enable --now openvpn@server
Created symlink from /etc/systemd/system/multi-user.target.wants/openvpn@server.service to /usr/lib/systemd/system/openvpn@.service.
[root@server ~]# systemctl status openvpn@server
● openvpn@server.service - OpenVPN Robust And Highly Flexible Tunneling Application On server
   Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2021-07-06 06:58:24 UTC; 31min ago
 Main PID: 4438 (openvpn)
   Status: "Initialization Sequence Completed"
   CGroup: /system.slice/system-openvpn.slice/openvpn@server.service
           └─4438 /usr/sbin/openvpn --cd /etc/openvpn/ --config server.conf
[root@server ~]$ 

```

***Настройка клиента***

7. Секретный ключ с сервера:
```
[root@client ~]# cat > /etc/openvpn/static.key <<EOF
#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
304eec03b178ccaa1f0353667058a4d7
cc9d3b605fe84f7441cae1a1153fbb12
6c55fa84ee72c04d3ca1875b02726c38
a79b64200ee8946c8525478a4cec9af2
509cac9e555db45a96a3850f6657f656
0b24792ff70c84c5de85268f69d41a33
4dd6a8d8f88e2c88a98d0c007511b69f
5820ecf37328573f068ad856e629956c
fa898f7e29b45da04f73a41bc72b7fe1
e8ca46df0e29d9734212cc92b1d86ab8
3a2e704b4f11d76d045e6654fef8224c
3da0b5be35e0431ab5376f011d318d07
89e828436b6ada625eb3e10f8d77223e
c584516ec2d5567acc9a8f30030deaba
115ac10e092daba2833149c0a6eeea3c
5bee7d589ea5105adbc05c792c3eabba
-----END OpenVPN Static key V1-----

EOF
```

8. Config tap режима:
```
[root@client ~]# cat > /etc/openvpn/server.conf <<EOF
dev tap
remote 192.168.10.10
ifconfig 172.16.10.2 255.255.255.0
topology subnet
route 10.0.0.1 255.255.255.255 172.16.10.1
secret /etc/openvpn/static.key
compress lzo
status /var/log/openvpn-status.log
log /var/log/openvpn.log
verb 3
EOF
```

9. Запуск:
```
[root@client ~]# systemctl enable --now openvpn@server
Created symlink from /etc/systemd/system/multi-user.target.wants/openvpn@server.service to /usr/lib/systemd/system/openvpn@.service.
[root@client ~]# systemctl status openvpn@server
● openvpn@server.service - OpenVPN Robust And Highly Flexible Tunneling Application On server
   Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2021-07-06 06:59:19 UTC; 34min ago
 Main PID: 4416 (openvpn)
   Status: "Initialization Sequence Completed"
   CGroup: /system.slice/system-openvpn.slice/openvpn@server.service
           └─4416 /usr/sbin/openvpn --cd /etc/openvpn/ --config server.conf

Jul 06 06:59:19 client systemd[1]: Starting OpenVPN Robust And Highly Flexible Tunneling Application On server...
Jul 06 06:59:19 client systemd[1]: Started OpenVPN Robust And Highly Flexible Tunneling Application On server.
[root@client ~]# 
```

10. Проверка маршрутов:

10.1 Server
```
[root@server ~]# ip route
default via 10.0.2.2 dev eth0 proto dhcp metric 100 
10.0.0.2 via 172.16.10.2 dev tap0 
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
172.16.10.0/24 dev tap0 proto kernel scope link src 172.16.10.1 
192.168.10.0/24 dev eth1 proto kernel scope link src 192.168.10.10 metric 101 
```
 - ping
 
```
[vagrant@server ~]$ ping -I 10.0.0.1 10.0.0.2
PING 10.0.0.2 (10.0.0.2) from 10.0.0.1 : 56(84) bytes of data.
64 bytes from 10.0.0.2: icmp_seq=1 ttl=64 time=1.91 ms
64 bytes from 10.0.0.2: icmp_seq=2 ttl=64 time=0.691 ms
64 bytes from 10.0.0.2: icmp_seq=3 ttl=64 time=0.774 ms
64 bytes from 10.0.0.2: icmp_seq=4 ttl=64 time=0.669 ms
^C
--- 10.0.0.2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3011ms
rtt min/avg/max/mdev = 0.669/1.013/1.919/0.524 ms
[vagrant@server ~]$ 

```
10.2 Client
```
[root@client ~]# ip route
default via 10.0.2.2 dev eth0 proto dhcp metric 100 
10.0.0.1 via 172.16.10.1 dev tap0 
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
172.16.10.0/24 dev tap0 proto kernel scope link src 172.16.10.2 
192.168.10.0/24 dev eth1 proto kernel scope link src 192.168.10.11 metric 101 
```
- ping
```
[root@client ~]# ping -I 10.0.0.2 10.0.0.1
PING 10.0.0.1 (10.0.0.1) from 10.0.0.2 : 56(84) bytes of data.
64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=0.662 ms
64 bytes from 10.0.0.1: icmp_seq=2 ttl=64 time=0.805 ms
64 bytes from 10.0.0.1: icmp_seq=3 ttl=64 time=0.776 ms
^C
--- 10.0.0.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2001ms
rtt min/avg/max/mdev = 0.662/0.747/0.805/0.069 ms
[root@client ~]# 

```

11. Проверка скорости с помощью iperf3` в tap режиме:
```
[root@server ~]# iperf3 -s
```

```
[root@client ~]# iperf3 -c 172.16.10.1 -t 10 -i 5
Connecting to host 172.16.10.1, port 5201
[  4] local 172.16.10.2 port 36906 connected to 172.16.10.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-5.00   sec  76.2 MBytes   128 Mbits/sec   44    768 KBytes       
[  4]   5.00-10.01  sec  69.7 MBytes   117 Mbits/sec    0    793 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-10.01  sec   146 MBytes   122 Mbits/sec   44             sender
[  4]   0.00-10.01  sec   143 MBytes   120 Mbits/sec                  receiver

iperf Done.
[root@client ~]#                receiver
```

12. Изменение режима `tap` на `tun` и замер скорости  (конфиг `/etc/openvpn/server.conf`, systemctl restart openvpn@server.service):


```
[root@client ~]# iperf3 -c 172.16.10.1 -t 10 -i 5
Connecting to host 172.16.10.1, port 5201
[  4] local 172.16.10.2 port 36910 connected to 172.16.10.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-5.00   sec  79.8 MBytes   134 Mbits/sec   26    447 KBytes       
[  4]   5.00-10.00  sec  77.7 MBytes   130 Mbits/sec    0    558 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-10.00  sec   157 MBytes   132 Mbits/sec   26             sender
[  4]   0.00-10.00  sec   156 MBytes   131 Mbits/sec                  receiver#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
f22cd1e5b15c30c1a50178b2d14df740
8bc1d6c61605c8668836989d66dae390
50f58aa9694f394f1b7571a4f4ed441e
bcf9e9af07d3f9711ff7db39ba5fd937
cd9e1571d937a6b01515cb4452f7cd16
69ef74a7d70429a3e70a201d09595f19
bd6fedcc6adb127fecbc1285a8197d8e
50b4e4bfac627f749563e115c9a7cc07
f29a5ce908b23b55cd69945efd94b62a
16b8b1363c6502a27c9e1ea19b18503e
02d0d17be488abaf65d0e2a90373ea0b
e6d52bca4ebff68963aa02ad5fd15483
217a71690efc304f48e7d16189120055
68b37becc9216b0817bf3f641da9c4e8
d82d8c3b6d322d24a8aaf39c24e4b97a
db5b7f2d46b126b141a779f28ea60bdd
-----END OpenVPN Static key V1-----


iperf Done.
[root@client ~]# 

```

Результат: 
- в режиме `tun` скорость выше
  - режим `tap` если нужен L2, для остальных случаев режим `tun`.



***Поднять RAS на базе OpenVPN с клиентскими сертификатами.***


1. Инициализация pki на сервере в /etc/openvpn:

```
[root@server openvpn]# /usr/share/easy-rsa/3.0.8/easyrsa init-pki

init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /etc/openvpn/pki


[root@server openvpn]# 


```

2. Генерация ключей и сертификатов.


- Сертификат:
```
[root@server openvpn]# echo 'rasvpn' | /usr/share/easy-rsa/3.0.8/easyrsa build-ca nopass
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating RSA private key, 2048 bit long modulus
.................................................................................+++
..................+++
e is 65537 (0x10001)
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:
CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/etc/openvpn/pki/ca.crt


[root@server openvpn]# 
```

```
[root@server openvpn]# echo 'rasvpn' | /usr/share/easy-rsa/3.0.8/easyrsa gen-req server nopass
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating a 2048 bit RSA private key
.......................................................................................................................................................................+++
.+++
writing new private key to '/etc/openvpn/pki/easy-rsa-23501.bQAI0n/tmp.0Un2ph'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [server]:
Keypair and certificate request completed. Your files are:
req: /etc/openvpn/pki/reqs/server.req
key: /etc/openvpn/pki/private/server.key


[root@server openvpn]# 
```

- Подпись сертификата:
```
[root@server openvpn]# echo 'yes' | /usr/share/easy-rsa/3.0.8/easyrsa sign-req server server
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a server certificate for 825 days:

subject=
    commonName                = rasvpn


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: Using configuration from /etc/openvpn/pki/easy-rsa-23529.YSQfKD/tmp.7Kk1nt
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'rasvpn'
Certificate is to be certified until Oct  9 07:56:57 2023 GMT (825 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /etc/openvpn/pki/issued/server.crt


[root@server openvpn]# 

```

- Ключи Диффи-Хелмана:
```
[root@server openvpn]# /usr/share/easy-rsa/3.0.8/easyrsa gen-dh
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating DH parameters, 2048 bit long safe prime, generator 2
This is going to take a long time

...
..............................................+...................+......................................................................++*++*

DH parameters of size 2048 created at /etc/openvpn/pki/dh.pem
```

- Ключ (/etc/openvpn/ta.key) для tls-аутентификации:
```
[root@server openvpn]# openvpn --genkey --secret ta.key
[root@server openvpn]# 

```

- Для клиента:
```
[root@server openvpn]# echo 'client' | /usr/share/easy-rsa/3.0.8/easyrsa gen-req client nopass
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017
Generating a 2048 bit RSA private key
........+++
.................................+++
writing new private key to '/etc/openvpn/pki/easy-rsa-23614.2R6OdI/tmp.UOWPvb'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [client]:
Keypair and certificate request completed. Your files are:
req: /etc/openvpn/pki/reqs/client.req
key: /etc/openvpn/pki/private/client.key


[root@server openvpn]# 

```
```
[root@server openvpn]# echo 'yes' | /usr/share/easy-rsa/3.0.8/easyrsa sign-req client client
Using SSL: openssl OpenSSL 1.0.2k-fips  26 Jan 2017


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a client certificate for 825 days:

subject=
    commonName                = client


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: Using configuration from /etc/openvpn/pki/easy-rsa-23656.cPatGU/tmp.a1CJpm
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'client'
Certificate is to be certified until Oct  9 08:01:38 2023 GMT (825 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /etc/openvpn/pki/issued/client.crt


[root@server openvpn]# 

```

3. Конфигурационный файл сервера:
```
[root@server ~]# cat > /etc/openvpn/server.conf <<EOF
port 2395
proto udp
dev tun
ca /etc/openvpn/pki/ca.crt
cert /etc/openvpn/pki/issued/server.crt
key /etc/openvpn/pki/private/server.key
dh /etc/openvpn/pki/dh.pem
server 172.16.10.0 255.255.255.0
route 10.0.0.2 255.255.255.255
push "route 10.0.0.1 255.255.255.255"
client-to-client
client-config-dir /etc/openvpn/client
keepalive 10 120
compress lzo
persist-key
persist-tun
status /var/log/openvpn-status.log
log /var/log/openvpn.log
verb 3
EOF
```
```
[root@server ~]# systemctl restart openvpn@server
```

4. Конфигурация клиента:
```
[root@client ~]# cat > /etc/openvpn/client.conf <<EOF
dev tun
proto udp
remote 192.168.10.10 2395
client
resolv-retry infinite
ca ./ca.crt
cert ./client.crt
key ./client.key
compress lzo
persist-key
persist-tun
status /var/log/openvpn-client-status.log
log-append /var/log/openvpn-client.log
verb 3
EOF
```

5. Подключение:
- файлы перенесены:
  - /etc/openvpn/pki/ca.crt
  - /etc/openvpn/pki/issued/client.crt
  - /etc/openvpn/pki/private/client.key
  
```
[root@client ~]# openvpn --config /etc/openvpn/client.conf
```

7. Проверка:
```
[root@client ~]# ping 10.0.0.1
PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=0.679 ms
64 bytes from 10.0.0.1: icmp_seq=2 ttl=64 time=0.711 ms
64 bytes from 10.0.0.1: icmp_seq=3 ttl=64 time=0.793 ms
^C
--- 10.0.0.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 0.679/0.727/0.793/0.057 ms
[root@client ~]# 

```
















