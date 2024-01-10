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
filename="spark-2.2.1-bin-without-hadoop.zip"


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

cd $folderpath
unzip  $filename

mkdir -p /app/server/spark-2.2.1-bin-without-hadoop/sparkevetlogs/
mkdir -p /data/spark/data/

cat << EOF > /app/server/spark-2.2.1-bin-without-hadoop/conf/spark-defaults.conf
spark.master                     spark://centos20:7077
spark.eventLog.enabled           true
spark.eventLog.dir               file:///app/server/spark-2.2.1-bin-without-hadoop/sparkevetlogs
spark.eventLog.compress          true
spark.serializer                 org.apache.spark.serializer.KryoSerializer
spark.history.fs.logDirectory=file:///app/server/spark-2.2.1-bin-without-hadoop/sparkevetlogs
EOF



cat << EOF > /app/server/spark-2.2.1-bin-without-hadoop/conf/spark-env.sh
export JAVA_HOME=/app/server/jdk1.8.0_91/
export SPARK_HOME=/app/server/spark-2.2.1-bin-without-hadoop
export SPARK_CONF_DIR=${SPARK_HOME}/conf
export SPARK_PID_DIR=${SPARK_HOME}/pid
export SPARK_MASTER_HOST=centos20
export SPARK_MASTER_PORT=7077
export SPARK_MASTER_WEBUI_PORT=8080
export SPARK_WORKER_CORES=26
export SPARK_WORKER_MEMORY=12g
export SPARK_WORKER_WEBUI_PORT=8081
export SPARK_LOCAL_DIRS=/data/spark/data
EOF



cat << EOF > /app/server/spark-2.2.1-bin-without-hadoop/conf/slaves.template
centos21
centos22
centos23
centos24
EOF

rm -rf /app/server/spark-2.2.1-bin-without-hadoop.zip


#!/bin/bash

# 检查本机hostname是否在slaves.template中
hostname=$(hostname)
slaves_template="/app/server/spark-2.2.1-bin-without-hadoop/conf/slaves.template"

if grep -q "$hostname" "$slaves_template"; then
    echo 'Slave node'
    # 本机hostname在slaves.template中，启动Spark工作节点
    #/app/server/spark-2.2.1-bin-without-hadoop/sbin/start-slave.sh spark://centos20:7077
else
    echo 'Master Node'
    # 本机hostname不在slaves.template中，启动Spark主节点
    #/app/server/spark-2.2.1-bin-without-hadoop/sbin/start-master.sh
fi





#/app/server/spark-2.2.1-bin-without-hadoop/sbin/start-master.sh
#/app/server/spark-2.2.1-bin-without-hadoop/sbin/start-slave.sh   spark://centos20:7077

