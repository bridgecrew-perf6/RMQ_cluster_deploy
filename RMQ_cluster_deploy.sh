#! /bin/bash
# Для работы скрипта необходимо, чтобы на всех трех серверах были прописаны ssh-ключи машины,
# с которой скрипт запускается.
# Erlang-cookie используется дефолтный, гененириуемый на $SRV1.
### Устанавливаем переменные.
SRV1_IP='192.168.57.22'
SRV2_IP='192.168.57.33'
SRV3_IP='192.168.57.44'
SRV1_HOSTNAME='test1'
SRV2_HOSTNAME='test2'
SRV3_HOSTNAME='test3'
SRV_USERNAME='test_user'
RABBITMQ_DISTR_PATH='/soft/ansible/rabbitmq-smolensk/'
RABBITMQ_USER='admin'
RABBITMQ_PWD='123' #ChangeMe!
EX_SRV1="ssh $SRV_USERNAME@$SRV1_IP"
EX_SRV2="ssh $SRV_USERNAME@$SRV2_IP"
EX_SRV3="ssh $SRV_USERNAME@$SRV3_IP"
### Устанавливаем время.
echo 'Setting date and time...'
$EX_SRV1 'sudo timedatectl set-timezone Europe/Moscow && sudo timedatectl set-ntp 1'
$EX_SRV2 'sudo timedatectl set-timezone Europe/Moscow && sudo timedatectl set-ntp 1'
$EX_SRV3 'sudo timedatectl set-timezone Europe/Moscow && sudo timedatectl set-ntp 1'
echo 'Done.'
### Правим /etc/hosts на $SRV1.
echo 'Configuring /etc/hosts...'
$EX_SRV1 'sudo cp /etc/hosts /etc/hosts_BAK'
$EX_SRV1 "echo '127.0.0.1       localhost
127.0.1.1       $SRV1_HOSTNAME
$SRV2_IP        $SRV2_HOSTNAME
$SRV3_IP        $SRV3_HOSTNAME
#  The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters/' | sudo tee /etc/hosts > /dev/null"
### Правим /etc/hosts на $SRV2.
$EX_SRV2 'sudo cp /etc/hosts /etc/hosts_BAK'
$EX_SRV2 "echo '127.0.0.1       localhost
127.0.1.1       $SRV2_HOSTNAME
$SRV1_IP        $SRV1_HOSTNAME
$SRV3_IP        $SRV3_HOSTNAME
#  The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters/' | sudo tee /etc/hosts > /dev/null"
### Правим /etc/hosts на $SRV3.
$EX_SRV3 'sudo cp /etc/hosts /etc/hosts_BAK'
$EX_SRV3 "echo '127.0.0.1       localhost
127.0.1.1       $SRV3_HOSTNAME
$SRV1_IP        $SRV1_HOSTNAME
$SRV2_IP        $SRV2_HOSTNAME
#  The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters/' | sudo tee /etc/hosts > /dev/null"
echo 'Done.'
### Установка имени хостов.
echo 'Setting hostnames...'
$EX_SRV1 "sudo hostnamectl set-hostname $SRV1_HOSTNAME"
$EX_SRV2 "sudo hostnamectl set-hostname $SRV2_HOSTNAME"
$EX_SRV3 "sudo hostnamectl set-hostname $SRV3_HOSTNAME"
echo 'Done.'
### Выгружаем пакеты RabbitMQ.
echo 'Uploading packages...'
scp -r $RABBITMQ_DISTR_PATH $SRV_USERNAME@$SRV1_IP:/tmp
scp -r $RABBITMQ_DISTR_PATH $SRV_USERNAME@$SRV2_IP:/tmp
scp -r $RABBITMQ_DISTR_PATH $SRV_USERNAME@$SRV3_IP:/tmp
echo 'Done.'
### Устанавливаем RabbitMQ.
echo 'Installing RabbitMQ...'
$EX_SRV1 'sudo dpkg -i /tmp/rabbitmq-smolensk/*.deb && rm -rf /tmp/rabbitmq-smolensk'
$EX_SRV2 'sudo dpkg -i /tmp/rabbitmq-smolensk/*.deb && rm -rf /tmp/rabbitmq-smolensk'
$EX_SRV3 'sudo dpkg -i /tmp/rabbitmq-smolensk/*.deb && rm -rf /tmp/rabbitmq-smolensk'
echo 'Done.'
### Устанавливаем сервис-лимиты.
echo 'Configuring limits...'
$EX_SRV1 'echo 'ulimit -S -n 10240' | sudo tee /etc/default/rabbitmq-server > /dev/null'
$EX_SRV1 'sudo mkdir -p /etc/systemd/system/rabbitmq-server.service.d'
$EX_SRV1 'sudo chmod 755 /etc/systemd/system/rabbitmq-server.service.d'
$EX_SRV1 'sudo touch /etc/systemd/system/rabbitmq-server.service.d/override.conf'
$EX_SRV1 'sudo chmod 544 /etc/systemd/system/rabbitmq-server.service.d/override.conf'
$EX_SRV1 'echo 'LimitNOFILE=32768' | sudo tee /etc/systemd/system/rabbitmq-server.service.d/override.conf > /dev/null'
$EX_SRV2 'echo 'ulimit -S -n 10240' | sudo tee /etc/default/rabbitmq-server > /dev/null'
$EX_SRV2 'sudo mkdir -p /etc/systemd/system/rabbitmq-server.service.d'
$EX_SRV2 'sudo chmod 755 /etc/systemd/system/rabbitmq-server.service.d'
$EX_SRV2 'sudo touch /etc/systemd/system/rabbitmq-server.service.d/override.conf'
$EX_SRV2 'sudo chmod 544 /etc/systemd/system/rabbitmq-server.service.d/override.conf'
$EX_SRV2 'echo 'LimitNOFILE=32768' | sudo tee /etc/systemd/system/rabbitmq-server.service.d/override.conf > /dev/null'
$EX_SRV3 'echo 'ulimit -S -n 10240' | sudo tee /etc/default/rabbitmq-server > /dev/null'
$EX_SRV3 'sudo mkdir -p /etc/systemd/system/rabbitmq-server.service.d'
$EX_SRV3 'sudo chmod 755 /etc/systemd/system/rabbitmq-server.service.d'
$EX_SRV3 'sudo touch /etc/systemd/system/rabbitmq-server.service.d/override.conf'
$EX_SRV3 'sudo chmod 544 /etc/systemd/system/rabbitmq-server.service.d/override.conf'
$EX_SRV3 'echo 'LimitNOFILE=32768' | sudo tee /etc/systemd/system/rabbitmq-server.service.d/override.conf > /dev/null'
$EX_SRV1 'echo 'ulimit -S -n 10240' | sudo tee /etc/default/rabbitmq-server > /dev/null'
echo 'Done.'
### Включаем web-админку.
echo 'Enabling administrator interface...'
$EX_SRV1 'sudo rabbitmq-plugins enable rabbitmq_management'
$EX_SRV2 'sudo rabbitmq-plugins enable rabbitmq_management'
$EX_SRV3 'sudo rabbitmq-plugins enable rabbitmq_management'
echo 'Done.'
### Создаем пользователя и добавляем привелегии.
echo 'Adding user and privileges...'
$EX_SRV1 "sudo rabbitmqctl add_user $RABBITMQ_USER $RABBITMQ_PWD"
$EX_SRV1 "sudo rabbitmqctl set_user_tags $RABBITMQ_USER administrator"
$EX_SRV1 "sudo rabbitmqctl set_permissions $RABBITMQ_USER '.*' '.*' '.*'"
$EX_SRV2 "sudo rabbitmqctl add_user $RABBITMQ_USER $RABBITMQ_PWD"
$EX_SRV2 "sudo rabbitmqctl set_user_tags $RABBITMQ_USER administrator"
$EX_SRV2 "sudo rabbitmqctl set_permissions $RABBITMQ_USER '.*' '.*' '.*'"
$EX_SRV3 "sudo rabbitmqctl add_user $RABBITMQ_USER $RABBITMQ_PWD"
$EX_SRV3 "sudo rabbitmqctl set_user_tags $RABBITMQ_USER administrator"
$EX_SRV3 "sudo rabbitmqctl set_permissions $RABBITMQ_USER '.*' '.*' '.*'"
echo 'Done.'
### Синхронизируем /var/lib/rabbitmq/.erlang.cookie.
echo 'Starting .erlang.cookie sync...'
touch .erlang.cookie_tmp
$EX_SRV1 'sudo chmod 404 /var/lib/rabbitmq/.erlang.cookie'
scp $SRV_USERNAME@$SRV1_IP:/var/lib/rabbitmq/.erlang.cookie .erlang.cookie_tmp
$EX_SRV2 'sudo chmod 777 /var/lib/rabbitmq'
$EX_SRV3 'sudo chmod 777 /var/lib/rabbitmq'
$EX_SRV2 'sudo mv /var/lib/rabbitmq/.erlang.cookie /var/lib/rabbitmq/.erlang.cookie_BAK'
$EX_SRV3 'sudo mv /var/lib/rabbitmq/.erlang.cookie /var/lib/rabbitmq/.erlang.cookie_BAK'
scp .erlang.cookie_tmp $SRV_USERNAME@$SRV2_IP:/var/lib/rabbitmq/.erlang.cookie
scp .erlang.cookie_tmp $SRV_USERNAME@$SRV3_IP:/var/lib/rabbitmq/.erlang.cookie
$EX_SRV2 'sudo chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/'
$EX_SRV3 'sudo chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/'
rm -f .erlang.cookie_tmp
### Возвращаем корректные права.
$EX_SRV1 'sudo chmod 400 /var/lib/rabbitmq/.erlang.cookie'
$EX_SRV2 'sudo chmod 400 /var/lib/rabbitmq/.erlang.cookie'
$EX_SRV3 'sudo chmod 400 /var/lib/rabbitmq/.erlang.cookie'
$EX_SRV2 'sudo chmod 755 /var/lib/rabbitmq'
$EX_SRV3 'sudo chmod 755 /var/lib/rabbitmq'
echo 'Done.'
### Перезапускаем службы.
echo 'Restarting services... It may take a long time!'
$EX_SRV1 'sudo systemctl daemon-reload && sudo systemctl restart rabbitmq-server'
$EX_SRV2 'sudo systemctl daemon-reload && sudo systemctl restart rabbitmq-server'
$EX_SRV3 'sudo systemctl daemon-reload && sudo systemctl restart rabbitmq-server'
echo 'Done.'
### Присоединяем ноду 2 и 3 к кластеру.
echo 'Starting nodes clustering...'
$EX_SRV2 'sudo rabbitmqctl stop_app'
$EX_SRV2 "sudo rabbitmqctl join_cluster rabbit@$SRV1_HOSTNAME"
$EX_SRV2 'sudo rabbitmqctl start_app'
$EX_SRV3 'sudo rabbitmqctl stop_app'
$EX_SRV3 "sudo rabbitmqctl join_cluster rabbit@$SRV1_HOSTNAME"
$EX_SRV3 'sudo rabbitmqctl start_app'
echo 'Done.'
echo 'Configuring HA policy...'
$EX_SRV1 "sudo rabbitmqctl set_policy ha-all \".*\" '{\"ha-mode\":\"all\"}'"
echo 'Done.'
echo 'Deploy is done!'
echo "http://$SRV1_IP:15672"
echo "http://$SRV2_IP:15672"
echo "http://$SRV3_IP:15672"
exit 0
