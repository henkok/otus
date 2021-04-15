* 1 * Создайте свой кастомный образ nginx на базе alpine. 
После запуска nginx должен
отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx)

(Dockerfile и сопутствующие файлы приложены)

команда для запуска - docker run -d -p 8081:80 mrbrokenpc/nginx

```
[test@localhost docker]$ curl localhost:8081

<!DOCTYPE html>
<html>
<head>
<title>Welcome to my nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>


<p>Custom web page for homework 18 - Docker</p>

</body>
</html>
[test@localhost docker]$
```


* 2 * Определите разницу между контейнером и образом

Docker-образ — предназначен только для запуска, именно из него создается контейнер. Включает в свой состав приложение и его окружение. При этом есть возможность создавать новые образы, изменять существующие и т.д.
Контейнер - это развернутый из образа и работающий экземпляр приложения и окружения


* 3 * Можно ли в контейнере собрать ядро?
Собрать можно, но работать с ним нельзя, т.к. контейнер использует системное ядро


* 4 * Собранный образ необходимо запушить в docker hub и дать ссылку на ваш
репозиторий.

https://hub.docker.com/r/mrbrokenpc/nginx