#!/bin/bash
yum install -y epel-release
yum install -y pam_script
groupadd admin
useradd test -s /bin/bash
useradd test_week -s /bin/bash
usermod -aG admin test
echo "test:123456" | chpasswd
echo "test_week:123456" | chpasswd
cat <<'EOT' > /etc/pam_script
#!/bin/bash

if groups $PAM_USER | grep admin > /dev/null
then
	exit 0
fi
if [[ `date +%u` > 5 ]]
then
	exit 1
fi
EOT
chmod +x /etc/pam_script
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i "2i auth  required  pam_script.so"  /etc/pam.d/sshd
date 04031700
systemctl restart sshd


# задание 2

curl -fsSL https://get.docker.com/ | sh
usermod -aG docker test
cat <<'EOT' > /etc/polkit-1/rules.d/01-systemd.rules
polkit.addRule(function(action, subject) {
 if (action.id.match("org.freedesktop.systemd1.manage-units") &&
subject.user === "test") {
 return polkit.Result.YES;
 }
});
EOT




















