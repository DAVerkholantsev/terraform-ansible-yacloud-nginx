# Terraform and Ansible code fore create instance with Ubuntu 22.04 and deploy nginx.
Terraform create Yandex Cloud resouces:
* VPC
* LAN
* Subnet
* Internet_gateway
* load balancer
* target group

Ansible deploy web-server:
* install Nginx
* copy config file

for example i used https://github.com/gabrielecirulli/2048
To start:
 create account https://console.cloud.yandex.ru/
 create catalog
 get token https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb
 set vars in ~/providers.tf to correct creation you YandexCloud resources run:
 ~/terraform:
 * terraform init
 * terraform apply
 ~/ansible^
 * create host
 * ansible-playbook main.yml
