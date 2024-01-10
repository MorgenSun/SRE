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


sh /root/opensourceshell/25jdk17.sh



folderpath="/app/server/"
filename1="jenkins-fontconfig.zip"


#Judge if download.mylab.local host has been recorded into /etc/hosts
hostrecord=$(cat /etc/hosts| grep download | wc -l)
if [ $hostrecord -lt 1 ];then
  echo  192.168.31.100 download.mylab.local >> /etc/hosts
else
  info 'Download.mylab.local record already existed'
fi

#Download the installation package in private cloud depends on nginx
if [ -d $folderpath ];then
   wget http://download.mylab.local:8888/$filename1 -P $folderpath >/dev/null 2>&1
#   wget http://download.mylab.local:8888/$filename2 -P $folderpath >/dev/null 2>&1
else
  mkdir -p $folderpath
  info "$folderpath folder has been created"
  wget http://download.mylab.local:8888/$filename1 -P $folderpath >/dev/null 2>&1
#  wget http://download.mylab.local:8888/$filename2 -P $folderpath >/dev/null 2>&1
fi




if [ $? -eq 0 ];
then

    info "$filename Package Install Sucessfully"
else
    info "$filename Package Install Failed"
    exit 1
fi



cd $folderpath
unzip $filename1
cd /app/server/jenkins-fontconfig
yum localinstall -y  *
rm -rf /app/server/jenkins-fontconfig*


