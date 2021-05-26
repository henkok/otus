#  Статическая и динамическая маршрутизация, OSPF


- Поднять три виртуалки
- Объединить их разными vlan
 - Поднять OSPF между машинами на базе Quagga
 - Изобразить ассиметричный роутинг
 - Сделать один из линков "дорогим", но что бы при этом роутинг был симметричным


## Выполнено:

- Vagrantfile и ansible плейбуки
  - роутеры r1,r2 и r3.
  
  Карта:

 ![Image 1]( ) 
 

## Проверка:
1. Симметричный роутинг для сети за r2:
```
[vagrant@r1 ~]$ tracepath -n 10.10.20.1
 1?: [LOCALHOST]                                         pmtu 1500
 1:  10.10.20.1                                            0.567ms reached
 1:  10.10.20.1                                            0.584ms reached
     Resume: pmtu 1500 hops 1 back 1 

```

2. Изменение стоимости пути между r1 и r2 для ассиметричного роутинга:
```
r1# conf t
r1(config)# int eth2
r1(config-if)# ip ospf  cost  1000
r1(config-if)# end
r1# ex

[vagrant@r1 ~]$ tracepath -n 10.10.20.1
 1?: [LOCALHOST]                                         pmtu 1500
 1:  192.168.255.9                                         0.477ms 
 1:  192.168.255.9                                         0.518ms 
 2:  10.10.20.1                                            0.915ms reached
     Resume: pmtu 1500 hops 2 back 2 

```

3. Сделать один из линков "дорогим", но что бы при этом роутинг был симметричным:
 - для интерфейса eth3 192.168.255.6 роутера r3 поднимается тоимость до 1000
```
[vagrant@r3 ~]$ sudo vtysh

Hello, this is Quagga (version 0.99.22.4).
Copyright 1996-2005 Kunihiro Ishiguro, et al.

r3# conf t
r3(config)# int eth3
r3(config-if)# ip ospf  cost  1000
r3(config-if)# end
r3# ex
[vagrant@r3 ~]$ 
```
 - проверка с роутера r1
```
[vagrant@r1 ~]$ tracepath -n 10.10.20.1
 1?: [LOCALHOST]                                         pmtu 1500
 1:  10.10.20.1                                            0.455ms reached
 1:  10.10.20.1                                            0.424ms reached

```



