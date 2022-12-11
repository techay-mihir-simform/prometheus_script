#! /bin/bash

set -e

net=`which netstat > /dev/null; echo $?`
if [ $net == 1 ]; then
    sudo apt-get install net-tools
fi

user=`cat /etc/group | grep node_exporter > /dev/null; echo $?`
if [ $user == 1 ];then 
    sudo useradd --no-create-home --shell /bin/false node_exporter
fi

check=`which wget > /dev/null; echo $?`
if [ $check == 1 ]; then
    sudo apt-get update
    sudo apt-get install wget
fi

if [ ! -f node_exporter-1.5.0.linux-amd64.tar.gz ]; then
    wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
fi

if [ ! -e node_exporter-1.5.0.linux-amd64 ]; then
    tar -xvzf node_exporter-1.5.0.linux-amd64.tar.gz
fi


service=`netstat -tnlp | grep 9100 >> /dev/null; echo $?`
if [ $service == 1 ]; then
    sudo cp node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin
fi

sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

sudo touch /etc/systemd/system/node_exporter.service
sudo cp ./node_exporter.service /etc/systemd/system/node_exporter.service


sudo systemctl daemon-reload
sudo systemctl restart node_exporter
sudo systemctl enable node_exporter
sudo systemctl status node_exporter

netstat -tnlp
