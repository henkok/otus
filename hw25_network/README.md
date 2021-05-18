
# //== Задание ==\\

## Планируемая архитектура
построить следующую архитектуру

Сеть office1
- 192.168.2.0/26      - dev
- 192.168.2.64/26    - test servers
- 192.168.2.128/26  - managers
- 192.168.2.192/26  - office hardware

Сеть office2
- 192.168.1.0/25      - dev
- 192.168.1.128/26  - test servers
- 192.168.1.192/26  - office hardware


Сеть central
- 192.168.0.0/28    - directors
- 192.168.0.32/28  - office hardware
- 192.168.0.64/26  - wifi

```
Office1 ---\
      -----> Central --IRouter --> internet
Office2----/
```
### Итого должны получится следующие сервера
- inetRouter
- centralRouter
- office1Router
- office2Router
- centralServer
- office1Server
- office2Server

## Теоретическая часть
- Найти свободные подсети
- Посчитать сколько узлов в каждой подсети, включая свободные
- Указать broadcast адрес для каждой подсети
- проверить нет ли ошибок при разбиении

## Практическая часть
- Соединить офисы в сеть согласно схеме и настроить роутинг
- Все сервера и роутеры должны ходить в инет черз inetRouter
- Все сервера должны видеть друг друга
- у всех новых серверов отключить дефолт на нат (eth0), который вагрант поднимает для связи
- при нехватке сетевых интервейсов добавить по несколько адресов на интерфейс

# //== Выполнение ==\\

## Теоретическая часть

![netmap](https://github.com/henkok/otus/blob/master/hw25_network/networkmap.png?raw=true)

### Для построения итогового стенда были взяты сети:
#### конечные хосты:
- 192.168.2.64/26 - TestServers Office1
- 192.168.1.128/26 - TestServers Office2
- 192.168.0.2/28 - CentralServer
#### сети между роутерами:
- 192.168.255.0/30 - between centralRouter and inetRouter
- 192.168.255.4/30 - between centralRouter and Office1Router
- 192.168.255.8/30 - between centralRouter and Office2Router

### Общий список сетей

1. Сеть office1
    - 192.168.2.0/26 - dev
        * диапазон адресов хостов: **192.168.2.1-192.168.2.62**
        * кол-во адресов хостов: **62**
        * broadcast: **192.168.2.63**
    - 192.168.2.64/26 - test servers
        * диапазон адресов хостов: **192.168.2.65-192.168.2.126**
        * кол-во адресов хостов: **62**
        * broadcast: **192.168.2.127**
    - 192.168.2.128/26 - managers
        * диапазон адресов хостов: **192.168.2.129-192.168.2.190**
        * кол-во адресов хостов: **62**
        * broadcast: **192.168.2.191**
    - 192.168.2.192/26 - office hardware
        * диапазон адресов хостов: **192.168.2.193-192.168.2.254**
        * кол-во адресов хостов: **62**
        * broadcast: **192.168.2.254**

2. Сеть office2
    - 192.168.1.0/25 - dev
        * диапазон адресов хостов: **192.168.1.1-192.168.1.126**
        * кол-во адресов хостов: **126**
        * broadcast: **192.168.1.127**
    - 192.168.1.128/26 - test servers
        * диапазон адресов хостов: **192.168.1.129-192.168.1.190**
        * кол-во адресов хостов: **62**
        * broadcast: **192.168.1.191**
    - 192.168.1.192/26 - office hardware
        * hosts range: **192.168.1.193-192.168.1.254**
        * кол-во адресов хостов: **62**
        * broadcast: **192.168.1.255**

3. Сеть central
    - 192.168.0.0/28 - directors
        * диапазон адресов хостов: **192.168.0.1-192.168.0.14**
        * кол-во адресов хостов: **14**
        * broadcast: **192.168.0.15**
    - 192.168.0.32/28 - office hardware
        * диапазон адресов хостов: **192.168.0.33-192.168.0.46**
        * кол-во адресов хостов: **14**
        * broadcast: **192.168.0.47**
    - 192.168.0.64/26 - wifi
        * диапазон адресов хостов: **192.168.0.65-192.168.0.126**
        * кол-во адресов хостов: **62**
        * broadcast: **192.168.0.127**

4. Сеть router-net
    - 192.168.255.0/30
        * диапазон адресов хостов: **192.168.255.1-192.168.255.2**
        * кол-во адресов хостов: **2**
        * broadcast: **192.168.0.3**

5. Сеть office1-net
    - 192.168.255.4/30
        * диапазон адресов хостов: **192.168.255.5-192.168.255.6**
        * кол-во адресов хостов: **2**
        * broadcast: **192.168.255.7**
		
6. Сеть office2-net
    - 192.168.255.8/30
        * диапазон адресов хостов: **192.168.255.9-192.168.255.10**
        * кол-во адресов хостов: **2**
        * broadcast: **192.168.255.11**
		
## Практическая часть



### Проверка доступности

** проводилась с office1Server **


```
[root@office1Server ~]# ping 192.168.0.2 
PING 192.168.0.2 (192.168.0.2) 56(84) bytes of data.
64 bytes from 192.168.0.2: icmp_seq=1 ttl=62 time=1.46 ms
64 bytes from 192.168.0.2: icmp_seq=2 ttl=62 time=1.95 ms
^C
--- 192.168.0.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 1.463/1.709/1.956/0.249 ms
[root@office1Server ~]# ping 192.168.1.130
PING 192.168.1.130 (192.168.1.130) 56(84) bytes of data.
64 bytes from 192.168.1.130: icmp_seq=1 ttl=61 time=1.85 ms
64 bytes from 192.168.1.130: icmp_seq=2 ttl=61 time=2.18 ms
^C
--- 192.168.1.130 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1003ms
rtt min/avg/max/mdev = 1.855/2.021/2.187/0.166 ms
[root@office1Server ~]# ping 192.168.255.1
PING 192.168.255.1 (192.168.255.1) 56(84) bytes of data.
64 bytes from 192.168.255.1: icmp_seq=1 ttl=62 time=1.91 ms
64 bytes from 192.168.255.1: icmp_seq=2 ttl=62 time=1.53 ms
^C
--- 192.168.255.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1005ms
rtt min/avg/max/mdev = 1.530/1.720/1.911/0.194 ms
[root@office1Server ~]# 

```
```
[root@office1Server ~]# ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=57 time=48.4 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=57 time=48.9 ms
^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1003ms
rtt min/avg/max/mdev = 48.437/48.671/48.906/0.321 ms
[root@office1Server ~]# traceroute 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  gateway (192.168.2.65)  0.474 ms  0.418 ms  0.399 ms
 2  192.168.255.5 (192.168.255.5)  0.718 ms  0.683 ms  0.665 ms
 3  192.168.255.1 (192.168.255.1)  1.348 ms  1.342 ms  1.248 ms
 4  *^C
[root@office1Server ~]#
```



