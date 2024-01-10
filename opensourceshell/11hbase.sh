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

filename="hbase-2.4.6-bin.tar.gz"
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
tar -zxvf $filename
rm -rf $filename
chown -R admin:root /app/server/hbase-2.4.6
chmod 755 -R /app/server/hbase-2.4.6


hbaserootenvrecord=$(cat /etc/profile|grep HBASE_HOME | wc -l)
if [ $hbaserootenvrecord -lt 1 ];then
  echo 'export HBASE_HOME=/app/server/hbase-2.4.6/'>> /etc/profile
  echo 'export PATH=$PATH:$HBASE_HOME/bin' >> /etc/profile

fi

source /etc/profile

echo 'export JAVA_HOME=/app/server/jdk1.8.0_91' >> /app/server/hbase-2.4.6/conf/hbase-env.sh
echo 'export HBASE_CLASSPATH=/app/server/hadoop-3.3.1/etc/hadoop'>> /app/server/hbase-2.4.6/conf/hbase-env.sh
echo 'export HBASE_MANAGES_ZK=false'>> /app/server/hbase-2.4.6/conf/hbase-env.sh
echo 'export HADOOP_HOME=/app/server/hadoop-3.3.1/'>> /app/server/hbase-2.4.6/conf/hbase-env.sh


mkdir -p  /data/hbase/tmp
chown -R admin:root /data/hbase/tmp
chmod 755 -R  /data/hbase/tmp

echo '
<configuration>
	<property>
		<name>hbase.rootdir</name>
		<value>hdfs://192.168.31.20:9820/hbase</value>
	</property>
	<property>
		<name>hbase.zookeeper.quorum</name>
		<value>centos20,centos21,centos22,centos23,centos24</value>
	</property>
	<property>
		<name>hbase.zookeeper.property.clientPort</name>
		<value>2181</value>
	</property>
	<property>
		<name>hbase.cluster.distributed</name>
		<value>true</value>
	</property>
	<property>
		<name>hbase.zookeeper.property.dataDir</name>
		<value>/data/zookeeper</value>
	</property>
	<property>
		<name>hbase.tmp.dir</name>
		<value>/data/hbase/tmp</value>
	</property>
	<property>
        <name>hbase.wal.provider</name>
        <value>filesystem</value>
 	</property>
	<property>
		<name>hbase.unsafe.stream.capability.enforce</name>
		<value>false</value>
	</property>
</configuration>
' >    /app/server/hbase-2.4.6/conf/hbase-site.xml


echo '192.168.31.22' > /app/server/hbase-2.4.6/conf/regionservers
echo '192.168.31.23' >> /app/server/hbase-2.4.6/conf/regionservers
echo '192.168.31.24' >> /app/server/hbase-2.4.6/conf/regionservers


#!/bin/bash

# 获取主机名
hostname=$(hostname)

# 使用case语句进行判断
case $hostname in
  centos20)
    su - admin -c '/app/server/hbase-2.4.6/bin/hbase-daemon.sh start master'
    ;;
  centos21)
    su - admin -c '/app/server/hbase-2.4.6/bin/hbase-daemon.sh start master'
    ;;
  *)
    su - admin -c '/app/server/hbase-2.4.6/bin/hbase-daemon.sh start regionserver'
    ;;
esac



