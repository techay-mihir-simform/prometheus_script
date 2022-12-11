#!/bin/bash

set -e 

net=`which netstat > /dev/null; echo $?`
if [ $net == 1 ]; then
    sudo apt-get install net-tools
fi

user=`cat /etc/group | grep prome > /dev/null; echo $?`
if [ $user == 1 ];then 
    sudo useradd --no-create-home --shell /bin/false prome
fi

if [[ ! -e /etc/prometheus ]]; then
    sudo mkdir /etc/prometheus
fi

if [[ ! -e /var/lib/prometheus ]]; then
    sudo mkdir /var/lib/prometheus
fi


check=`which wget > /dev/null; echo $?`
if [ $check == 1 ]; then
    sudo apt-get update
    sudo apt-get install wget
fi

if [ ! -f prometheus-2.37.5.linux-amd64.tar.gz ]; then
    wget https://github.com/prometheus/prometheus/releases/download/v2.37.5/prometheus-2.37.5.linux-amd64.tar.gz
fi


if [ ! -e prometheus-2.37.5.linux-amd64 ]; then
    tar -xvzf prometheus-2.37.5.linux-amd64.tar.gz
fi

service=`netstat -tnlp | grep 9090 >> /dev/null; echo $?`
if [ $service == 1 ]; then
    sudo cp prometheus-2.37.5.linux-amd64/prometheus /usr/local/bin/
    sudo cp prometheus-2.37.5.linux-amd64/promtool /usr/local/bin/
fi


sudo chown prome:prome /usr/local/bin/prometheus
sudo chown prome:prome /usr/local/bin/promtool

sudo cp -r prometheus-2.37.5.linux-amd64/consoles /etc/prometheus
sudo cp -r prometheus-2.37.5.linux-amd64/console_libraries /etc/prometheus

sudo chown -R prome:prome /etc/prometheus/consoles
sudo chown -R prome:prome /etc/prometheus/console_libraries
sudo chown -R prome:prome /var/lib/prometheus

sudo touch /etc/prometheus/prometheus.yml  
cp ./prometheus.yml /etc/prometheus/prometheus.yml 


sudo touch /etc/systemd/system/prometheus.service
sudo cp ./prometheus.service /etc/systemd/system/prometheus.service

sudo systemctl daemon-reload
sudo systemctl restart prometheus
sudo systemctl enable prometheus
sudo systemctl status prometheus


netstat -tnlp
