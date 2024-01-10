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
cluster-enabled yes
cluster-config-file /app/server/redis-5.0.5/redisclusterconfig.conf
cluster-node-timeout 15000
maxmemory 128mb
maxmemory-policy allkeys-lru
client-output-buffer-limit normal 0 0 0
repl-backlog-size 64mb
cluster-require-full-coverage no
latency-monitor-threshold 10
client-output-buffer-limit slave 2gb 1gb 60
no-appendfsync-on-rewrite yes
EOF

mkdir -p /export/log/redis/
mkdir -p /export/redis/redis_data
chmod 755 -R /export/log/redis/
chmod 755 -R /export/log/redis/


/app/server/redis-5.0.5/src/redis-server  /app/server/redis-5.0.5/redis.conf 



redisnodescount=$(/app/server/redis-5.0.5/src/redis-cli cluster nodes| wc -l)
if [ $redisnodescount -lt 6 ];then
    hostname
    master1=192.168.31.20
    master2=192.168.31.21
    master3=192.168.31.22
    slave1=192.168.31.23
    slave2=192.168.31.24
    slave3=192.168.31.25
    /app/server/redis-5.0.5/src/redis-cli --cluster create $master1:6379 $master2:6379 $master3:6379 $slave1:6379 $slave2:6379 $slave3:6379   --cluster-replicas 1
fi


#/app/server/redis-5.0.5/src/redis-cli cluster nodes



