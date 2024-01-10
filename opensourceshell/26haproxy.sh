#!/bin/sh
#定义颜色变量 用于Echo警告信息
#http://mylablogsys.ddns.net:6000/readlog
clear
RED='\E[1;31m'   # 红
GREEN='\E[1;32m' # 绿
YELOW='\E[1;33m' # 黄
BLUE='\E[1;34m'  # 蓝
PINK='\E[1;35m'  # 粉红
SHAN='\E[33;5m'  # 闪烁
RES='\E[0m'      # 清除颜色


function alert() {
    echo -e "${RED}$1${RES}"
    # echo "$1" # arguments are accessible through $1, $2,...
}

function info() {
    echo -e "${YELOW}$1${RES}"
    # echo "$1" # arguments are accessible through $1, $2,...
}

folderpath="/app/server/"
filename1="haproxy-2.9.1.tar.gz"
filename2="haproxyrpm.zip"

#Judge if download.mylab.local host has been recorded into /etc/hosts
hostrecord=$(cat /etc/hosts| grep download | wc -l)
if [ $hostrecord -lt 1 ];then
  echo  192.168.31.100 download.mylab.local >> /etc/hosts
else
  info 'Download.mylab.local record already existed'
fi

#Download the installation package in private cloud depends on nginx
if [ -d $folderpath ];then
  echo $folderpath ready
else
  mkdir -p $folderpath
  info "$folderpath folder has been created"
fi
wget http://download.mylab.local:8888/$filename1 -P $folderpath >/dev/null 2>&1
wget http://download.mylab.local:8888/$filename2 -P $folderpath >/dev/null 2>&1


if [ $? -eq 0 ];
then

    info "$filename Package Install Sucessfully"
else
    info "$filename Package Install Failed"
    exit 1
fi



cd $folderpath
tar -zxvf $filename1
unzip $filename2
cd /app/server/haproxyrpm
yum localinstall -y *
cd /app/server/haproxy-2.9.1/
make TARGET=linux-glibc USE_OPENSSL=1 USE_PCRE=1 USE_ZLIB=1
mkdir /app/server/haproxy/
make install PREFIX=/app/server/haproxy
mkdir /app/server/haproxy/etc/
rm -rf /app/server/haproxy-2.9.1
rm -rf /app/server/haproxyrpm
rm -rf /app/server/haproxyrpm.zip
rm -rf /app/server/haproxy-2.9.1.tar.gz


cat << EOF > /app/server/haproxy/etc/haproxy.conf
# Global settings
global
    log /dev/log local0
    log /dev/log local1 notice
    maxconn 4096

# Default settings for TCP mode
defaults
    log global
    mode tcp
    option tcplog
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

# Frontend configuration for your application
frontend main
    bind :8443
    default_backend app

# Backend configuration for your application
backend app
    balance roundrobin
    server centos20 192.168.31.20:6443 check
    server centos21 192.168.31.21:6443 check
    server centos22 192.168.31.22:6443 check

# Default settings for HTTP mode
defaults http
    mode http
    log global
    option httplog
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

# HAProxy Monitoring Config
frontend stats_frontend
    bind *:9000
    default_backend stats_backend

backend stats_backend
    stats enable
    stats uri /haproxy?stats
    stats hide-version
    stats auth admin:password
EOF


#/app/server/haproxy/sbin/haproxy -f /app/server/haproxy/etc/haproxy.conf