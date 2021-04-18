###
Подготовить стенд на Vagrant как минимум с одним сервером. На этом сервере используя Ansible необходимо развернуть nginx со следующими условиями:

- необходимо использовать модуль yum/apt
- конфигурационные файлы должны быть взяты из шаблона jinja2 с перемененными
- после установки nginx должен быть в режиме enabled в systemd
- должен быть использован notify для старта nginx после установки
- сайт должен слушать на нестандартном порту - 8080, для этого использовать переменные в Ansible
* Сделать все это с исполþзованием Ansible роли
###

### запуск

- vagrant up
- ansible
	- ansible-playbook playbooks/nginx.yml - для старта только playbook
	- ansible-playbook nginx_role.yml - для старта role
- проверка доступности 
	- curl http://192.168.11.150:8080
	- http://192.168.11.150:8080/
	