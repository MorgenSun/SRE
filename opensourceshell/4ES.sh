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


#Judge if download.mylab.local host has been recorded into /etc/hosts 
hostrecord=$(cat /etc/hosts| grep download | wc -l)
if [ $hostrecord -lt 1 ];then
  echo  192.168.31.100 download.mylab.local >> /etc/hosts
else
  info 'Download.mylab.local record already existed'
fi

filename="elasticsearch-5.4.3.tar.gz"
folderpath="/app/server/"

#Download the installation package in private cloud depends on nginx
if [ -d $folderpath ];then
   echo $folderpath ready
else
  mkdir -p $folderpath
  info "$folderpath folder has been created"

fi
wget http://download.mylab.local:8888/$filename -P $folderpath >/dev/null 2>&1
chmod 755 -R /app/server



if [ $? -eq 0 ];
then
    info "$filename Package Download Sucessfully"
else
    info "$filename Package Download Failed"
    exit 1
fi

cd $folderpath
tar -zxvf $filename >/dev/null 2>&1
info "File $filename extracted done"
rm -rf /app/server/$filename
info "File $filename removed done"

chown -R admin:root /app/server/elasticsearch-5.4.3

cat << EOF > /app/server/elasticsearch-5.4.3/config/elasticsearch.yml
cluster.name: es-cluster
path.data: /export/data/elasticsearch
path.logs: /export/log/elasticsearch
path.repo: /export/repo/
network.host: 0.0.0.0
http.port: 9200
discovery.zen.ping.unicast.hosts: ["192.168.31.20","192.168.31.21","192.168.31.22","192.168.31.23","192.168.31.24"]
bootstrap.system_call_filter: false
http.cors.enabled: true
http.cors.allow-origin: "*"
node.master: true
node.data: true
discovery.zen.minimum_master_nodes: 3
EOF


cat << EOF > /app/server/elasticsearch-5.4.3/config/jvm.options
-Xms1g
-Xmx1g
-XX:+UseConcMarkSweepGC
-XX:CMSInitiatingOccupancyFraction=75
-XX:+UseCMSInitiatingOccupancyOnly
-XX:+DisableExplicitGC
-XX:+AlwaysPreTouch
-server
-Xss1m
-Djava.awt.headless=true
-Dfile.encoding=UTF-8
-Djna.nosys=true
-Djdk.io.permissionsUseCanonicalPath=true
-Dio.netty.noUnsafe=true
-Dio.netty.noKeySetOptimization=true
-Dio.netty.recycler.maxCapacityPerThread=0
-Dlog4j.shutdownHookEnabled=false
-Dlog4j2.disable.jmx=true
-Dlog4j.skipJansi=true
-XX:+HeapDumpOnOutOfMemoryError
EOF


info "Kafka server.properties Config initial done"
#echo export ES_JAVA_OPTS="-Xms8g -Xmx8g" >> /etc/profiile

echo '* hard nofile 65536
* soft nofile 65536' >>  /etc/security/limits.conf

echo  'vm.max_map_count=262144'  >>  /etc/sysctl.conf

sysctl -p

mkdir -p /export/data/elasticsearch
mkdir -p /export/log/elasticsearch
mkdir -p /export/repo/
chown -R admin:root /export/data/elasticsearch
chown -R admin:root /export/log/elasticsearch
chown -R admin:root /export/repo/


export JAVA_HOME=/app/server/jdk1.8.0_91

su admin -c '/app/server/elasticsearch-5.4.3/bin/elasticsearch -d '

sleep 5
tail -f /export/log/elasticsearch/es-cluster.log