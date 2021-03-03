### 1. Сервис: скрипт, который мониторит log-файл на наличие ключевого слова
- запуск vagrant up logmonitoring
	- скрипт для vagrant logmonitoring.sh
		- /usr/bin/logalert.sh - скрипт с поиском слова
		- /etc/sysconfig/logalert - конфиг сервиса
		- /etc/systemd/system/logalert.service - unit файл
		- /etc/systemd/system/logalert.timer - unit-файл для таймера logalert.timer
		
		
### 2. Дополнить unit-файл сервиса httpd возможностью запустить несколько экземпляров сервиса с разными конфигурационными файлами.
- запуск vagrant up logmonitoring
	- скрипт для vagrant apache.sh
		- изменен параметр ExecStart unit файла для запуска с разными конфигами %i.conf
		- в конфигах изменены порт Listen, PidFile и директория для веб файлов
		- созданы директории для файлов и файлы index.html
### 3. Cервис: Kafka
- запуск vagrant up kafka
	- скрипт для vagrant kafka.sh
		- добавлены ограничения:
			- CPUShares=1500
			- MemoryLimit=3G
			- LimitCORE=infinity
			- LimitNOFILE=65536
		- Restart=on-abnormal - перезапускать автоматически, если выходит из строя нештатно

