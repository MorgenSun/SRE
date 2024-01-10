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
filename2="jdk-17_linux-x64_bin.rpm"

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
wget http://download.mylab.local:8888/$filename2 -P $folderpath >/dev/null 2>&1




if [ $? -eq 0 ];
then

    info "$filename2 Package Install Sucessfully"
else
    info "$filename2 Package Install Failed"
    exit 1
fi


rm -rf  /app/server/jdk1.8.0_91/
#sed -i '/JAVA_HOME=\/app\/server\/jdk1.8.0_91/s/^/#/' /etc/profile
#sed -i '/PATH=\$JAVA_HOME\/bin:\$PATH/s/^/#/' /etc/profile
#sed -i '/CLASSPATH=.:\$JAVA_HOME\/lib\/dt.jar:\$JAVA_HOME\/lib\/tools.jar/s/^/#/' /etc/profile

#
#sed -i '/JAVA_HOME=\/app\/server\/jdk1.8.0_91/s/^/#/' /root/.bashrc
#sed -i '/PATH=\$JAVA_HOME\/bin:\$PATH/s/^/#/' /root/.bashrc
#sed -i '/CLASSPATH=.:\$JAVA_HOME\/lib\/dt.jar:\$JAVA_HOME\/lib\/tools.jar/s/^/#/' /root/.bashrc
#


cd $folderpath
yum localinstall -y /app/server/$filename2
rm -rf /app/server/$filename2
echo 'export JAVA_HOME=/usr/lib/jvm/jdk-17-oracle-x64' >> /etc/profile
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >> /etc/profile

echo 'export JAVA_HOME=/usr/lib/jvm/jdk-17-oracle-x64' >> /root/.bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /root/.bashrc
echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >> /root/.bashrc
source /etc/profile
#/usr/bin/java -version


