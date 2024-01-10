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

filename="kafka-2.12-2.6.2.tgz"
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
tar -zxvf $filename >/dev/null 2>&1
info "File $filename extracted done"
rm -rf /app/server/$filename
info "File $filename removed done"
mkdir -p /data/kafka
info "Data folder initial done"

ip1=192.168.31.20
ip2=192.168.31.21
ip3=192.168.31.22
ip4=192.168.31.23
ip5=192.168.31.24

cat << EOF > /app/server/kafka_2.12-2.6.2/config/server.properties
port=9092
delete.topic.enable=true
num.network.threads=16
num.io.threads=32
socket.send.buffer.bytes=1048576
socket.receive.buffer.bytes=1048576
socket.request.max.bytes=104857600
log.dirs=/data/kafka
num.partitions=20
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=3
offsets.topic.num.partitions=50
log.cleaner.enable=true
log.cleanup.policy=delete
log.retention.hours=3
log.segment.bytes=1073741824
log.retention.check.interval.ms=6000
zookeeper.connect=$ip1:2181,$ip2:2181,$ip3:2181,$ip4:2181,$ip5:2181
zookeeper.connection.timeout.ms=100000
unclean.leader.election.enable=true
default.replication.factor=3
listeners=PLAINTEXT://:9092
EOF

info "Kafka server.properties Config initial done"


kafkaenv=$( cat /etc/profile| grep Xmx| grep KAF | wc -l)
if [ $kafkaenv -lt 1 ] ;then
  echo 'export KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"' >> /etc/profile
  echo export LOG_DIR="/app/server/kafka_2.12-2.6.2/kafkalogs/" >> /etc/profile
fi

source /etc/profile
/app/server/kafka_2.12-2.6.2/bin/kafka-server-start.sh  -daemon /app/server/kafka_2.12-2.6.2/config/server.properties

