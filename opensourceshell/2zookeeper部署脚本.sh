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

filename="zookeeper-3.6.3.tar.gz"
folderpath="/app/server/"
if [ -d $folderpath ];then
   echo $folderpath ready
else
  mkdir -p $folderpath
  info "$folderpath folder has been created"

fi
wget http://download.mylab.local:8888/$filename -P $folderpath >/dev/null 2>&1

chmod 755 -R /app/server
chown -R root:root /app/server/$filename


if [ $? -eq 0 ];
then
    info "$filename Package Download Sucessfully"
else
    info "$filename Package Download Failed"
    exit 1
fi

ip1=192.168.31.20
ip2=192.168.31.21
ip3=192.168.31.22
ip4=192.168.31.23
ip5=192.168.31.24


#caculate the real id value for every zookeeper server
ipinfo=$(hostname -I)
id=${ipinfo:12:13}
let myid=id+1

cd $folderpath
tar -zxvf $filename >/dev/null 2>&1
info "File $filename extracted done"
rm -rf /app/server/$filename
info "File $filename removed done"
mkdir -p  /data/zookeeper/log
info "Data Folder initial done"
echo $myid > /data/zookeeper/myid
info "Zookeeper ID initial done"



let idvalue1=${ip1:12:13}+1
let idvalue2=idvalue1+1
let idvalue3=idvalue2+1
let idvalue4=idvalue3+1
let idvalue5=idvalue4+1



cat << EOF > /app/server/apache-zookeeper-3.6.3-bin/conf/zoo.cfg
tickTime=2000
initLimit=60
syncLimit=5
dataDir=/data/zookeeper
dataLogDir=/data/zookeeper/log
snapCount=52500
clientPort=2181
maxClientCnxns=0
autopurge.snapRetainCount=5
autopurge.purgeInterval=24
4lw.commands.whitelist=*
server.$idvalue1=$ip1:2888:3888
server.$idvalue2=$ip2:2888:3888
server.$idvalue3=$ip3:2888:3888
server.$idvalue4=$ip4:2888:3888
server.$idvalue5=$ip5:2888:3888
EOF



info "Zookeeper server.properties Config initial done"

envrecord=$(cat /etc/profile | grep ZOO_LOG_DIR | wc -l)
if [ $envrecord -lt 1 ];then
  echo export ZOO_LOG_DIR="/app/server/apache-zookeeper-3.6.3-bin/zkserverlogs" >> /etc/profile
fi
source /etc/profile

chown -R root:root /app/server/
/app/server/apache-zookeeper-3.6.3-bin/bin/zkServer.sh start