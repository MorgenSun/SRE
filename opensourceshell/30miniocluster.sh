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
filename="minio"


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
wget http://download.mylab.local:8888/$filename -P $folderpath >/dev/null 2>&1



if [ $? -eq 0 ];
then

    info "$filename Package Install Sucessfully"
else
    info "$filename Package Install Failed"
    exit 1
fi





chmod 755 /app/server/minio
export MINIO_ROOT_USER=admin
export MINIO_ROOT_PASSWORD=Genomics1
mkdir -p /app/server/miniocluster/conf

mkdir -p /{minidata1,minidata2}
mkfs.ext4 /dev/vda
mount /dev/vda/ /minidata1
touch /minidata1/1
mkfs.ext4 /dev/vdb
mount /dev/vdb/ /minidata2
touch /minidata2/2
rm -rf /minidata1/*
rm -rf /minidata2/*
mkdir -p /minidata1/data1/
mkdir -p /minidata2/data2/
chmod 777 -R /minidata1/
chmod 777 -R /minidata2/

/app/server/minio server --config-dir /app/server/miniocluster/conf --address ":9000" --console-address ':9001'  \
http://192.168.31.20/minidata1/data1 http://192.168.31.20/minidata2/data2 \
http://192.168.31.21/minidata1/data1 http://192.168.31.21/minidata2/data2 \
http://192.168.31.22/minidata1/data1 http://192.168.31.22/minidata2/data2 \
http://192.168.31.23/minidata1/data1 http://192.168.31.23/minidata2/data2 \
http://192.168.31.24/minidata1/data1 http://192.168.31.24/minidata2/data2 >/app/server/miniocluster/log.log 2>&1 &



tail -f /app/server/miniocluster/log.log


#kill -9 $(ps -ef| grep mini | grep data | awk '{print $2}')