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


filename="redis-5.0.5.zip"
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



cd $folderpath
unzip $filename
rm -rf $filename



cat << EOF > /app/server/redis-5.0.5/redis.conf
daemonize yes
pidfile "/app/server/redis-5.0.5/redis_6379.pid"
bind 0.0.0.0
port 6379
logfile "/export/log/redis/redis_master_6379.log"
dbfilename "dump_6379.rdb"
dir "/export/redis/redis_data"
appendonly yes
appendfilename "appendonly_6379.aof"
appendfsync no
maxmemory 128mb
maxmemory-policy allkeys-lru
repl-backlog-size 64mb
latency-monitor-threshold 10
no-appendfsync-on-rewrite yes
EOF

mkdir -p /export/log/redis/
mkdir -p /export/redis/redis_data
chmod 755 -R /export/log/redis/
chmod 755 -R /export/log/redis/

/app/server/redis-5.0.5/src/redis-server  /app/server/redis-5.0.5/redis.conf


