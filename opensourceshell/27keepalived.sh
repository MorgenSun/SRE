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
filename1="keepalived-2.2.8.tar.gz"
filename2="keepalivedrpm.zip"

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

mkdir -p   /app/server/keepalived
cd $folderpath
tar -zxvf $filename1
unzip $filename2
cd /app/server/keepalivedrpm/
yum localinstall -y *
cd /app/server/keepalived-2.2.8/
./configure --prefix=/app/server/keepalived
make && sudo make install
echo 'export PATH=$PATH:/app/server/keepalived/bin' >> /etc/profile
rm -rf /app/server/keepalived-2.2.8*
rm -rf /app/server/keepalivedrpm*
mkdir -p /app/server/keepalived/logs/


cat << EOF > /app/server/keepalived/etc/keepalived/6443.conf
global_defs {
   router_id LVS_DEMO
}

vrrp_script chk_health {
    script "/usr/bin/ping -c 2 192.168.31.200" # 替换为您的健康检查脚本
    interval 2 # 检查间隔
    weight -5
}

vrrp_instance VI_1 {
    state MASTER  #BACKUP
    interface ens3 # 替换为您的网络接口名
    virtual_router_id 51
    priority 100  #99 #98
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.31.200
    }
    track_script {
        chk_health
    }
}
EOF


#/app/server/keepalived/sbin/keepalived  -f /app/server/keepalived/etc/keepalived/6443.conf
