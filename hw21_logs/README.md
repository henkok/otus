####Настраиваем центральный сервер для сбора логов

### Поднимаем 2 машины web и log на web поднимаем nginx на log настраиваем центральный лог сервер на любой системе на выбор

## Выбран rsyslog

## Настройка сервера

1. Установка
```
[root@log ~]# yum install rsyslog
[root@log ~]# systemctl enable rsyslog
[root@log ~]# systemctl start rsyslog
```

2. Конфигурирование 
```
[root@log ~]# vi /etc/rsyslog.conf
```
### разрешаем запуск сервера на обоих протоколах TCP/UDP
```
# Provides UDP syslog reception
$ModLoad imudp
$UDPServerRun 514

# Provides TCP syslog reception
$ModLoad imtcp
$InputTCPServerRun 514
```
### создание шаблона для сохранения логов
```
$template RemoteLogs,"/var/log/rsyslog/%HOSTNAME%/%PROGRAMNAME%.log"
*.* ?RemoteLogs
& ~
```

3. Перезапуск для применения настроек
```
[root@log ~]# systemctl restart rsyslog
```

## Настройка клиента

- на сервер будут отправляться все логи 

1. Создание конфигурационного файла vi /etc/rsyslog.d/remote.conf
#### указан адрес сервера
```
*.* @@192.168.145.148:514
```

2. Перезапуск
```
[root@web ~]# systemctl restart rsyslog
```

### Проверка

- каталоги на сервере логов
![server log](https://raw.githubusercontent.com/henkok/otus/master/hw21_logs/log_list.png)
- лог nginx
![log nginx](https://raw.githubusercontent.com/henkok/otus/master/hw21_logs/nginx.png)
