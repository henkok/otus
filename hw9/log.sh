#!/bin/bash

# времячко
time=$(date  +%Y-%m-%d\ %H:%M:%S)

# расположение лога
logpath=/var/log/nginx/access.log

# чтобы не бегать дважды
num=$(cat ./stopfile 2>/dev/null);status=$?
numlines=$(wc $logpath | awk '{print $1}')


# сравнение строк
if ! [ $numlines -ge $num ]
then
	starttime=$(awk '{print $4 $5}' $logpath | sed -n 1p)
	stoptime=$(awk '{print $4 $5}' $logpath | sed -n "$numlines"p)
	echo $numlines > ./stopfile
	# определение данные
	ip=$(awk '{print $1}' $logpath | sort | uniq -c | sort -rn | head -n 10)
	url=$(awk '{print $7}' $logpath | sort | uniq -c | sort -rn | head -n 10)
	cod=$(awk '{print $9}' $logpath | grep -v "-" | sort | uniq -c | sort -rn | head -n 10)
	# отправляем весточку
	echo -e "Временной промежуток:$starttime - $stoptime\n\n"Наиболее часто встречающиеся IP адреса:"\n$ip\n\n"Наиболее часто запрашиваемые URL адреса:"\n$url\n\n"Наиболее частые коды и ошибки:"\n$cod" && mail -s "Log report" root@localhost
else if ! [ $numlines -le $num ]
then
	starttime=$(awk '{print $4 $5}' $logpath | sed -n "$(($num+1))"p)
	stoptime=$(awk '{print $4 $5}' $logpath | sed -n "$numlines"p)
	echo $numlines > ./stopfile
	# определение данные
	ip=$(awk "NR>$(($num+1))"  $logpath | awk '{print $1}' | sort | uniq -c | sort -rn | head -n 10)
	url=$(awk "NR>$(($num+1))"  $logpath | awk '{print $7}' | sort | uniq -c | sort -rn | head -n 10 )
	cod=$(awk "NR>$(($num+1))"  $logpath |awk '{print $9}' | grep -v "-" | sort | uniq -c | sort -rn | head -n 10)
	# отправляем весточку
	echo -e "Временной промежуток:$starttime - $stoptime\n\n"Наиболее часто встречающиеся IP адреса:"\n$ip\n\n"Наиболее часто запрашиваемые URL адреса:"\n$url\n\n"Наиболее частые коды и ошибки:"\n$cod" && mail -s "Log report" root@localhost
else 
message=$"[$time] Данные не изменились"
	echo $message
	echo $message >> maillog.txt
fi
fi
