#!/bin/sh
#定义颜色变量 用于Echo警告信息
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



hostrecord=$(cat /etc/hosts| grep download | wc -l)
if [ $hostrecord -lt 1 ];then
  echo  192.168.31.100 download.mylab.local >> /etc/hosts
else
  info 'Download.mylab.local record already existed'
fi

wget http://download.mylab.local:8888/mysqlclient.zip -P /app/server/
cd /app/server/
unzip /app/server/mysqlclient.zip
cd mysqlclient
yum install * -y
rm -rf /app/server/mysqlclient
rm -rf /app/server/mysqlclient.zip

