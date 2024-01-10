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

folderpath="/app/server/"
filename="jdk1.8.0_91.zip"

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



cd $folderpath
unzip $filename

#For starting service remotely
javabashrcrecord=$(cat /root/.bashrc | grep JAVA_HOME | wc -l)
if [ $javabashrcrecord -lt 1 ];then
   echo 'export JAVA_HOME=/app/server/jdk1.8.0_91'  >> /root/.bashrc
   echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /root/.bashrc
   echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar'  >> /root/.bashrc
fi

#For starting service locally
javaprofilerecord=$(cat /etc/profile | grep JAVA_HOME | wc -l)
if [ $javaprofilerecord -lt 1 ];then
   echo 'export JAVA_HOME=/app/server/jdk1.8.0_91'  >> /etc/profile
   echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
   echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar'  >> /etc/profile
fi



#Judge if admin account existed or not
adminrecord=$(cat /etc/passwd | grep admin | wc -l)
if [ $adminrecord -lt 1 ];then
    useradd admin
fi


#for run java process remotely
javabashrcrecord=$(cat /home/admin/.bashrc | grep JAVA_HOME | wc -l)
if [ $javabashrcrecord -lt 1 ];then
   echo 'export JAVA_HOME=/app/server/jdk1.8.0_91'  >> /home/admin/.bashrc
   echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /home/admin/.bashrc
   echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar'  >> /home/admin/.bashrc
fi
#Clear the origin downloaded package
rm -rf /app/server/jdk1.8.0_91.zip