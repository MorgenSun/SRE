#!/bin/sh

# sh 5shell/1javainstallation.sh && sh 5shell/2zookeepercluster.sh  && sh 5shell/8hadoop.sh


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

filename="hadoop-3.3.1.zip"
folderpath="/app/server/"
if [ -d $folderpath ];then
  echo $folderpath ready
else
  mkdir -p $folderpath
  info "$folderpath folder has been created"
fi
wget http://download.mylab.local:8888/$filename -P $folderpath >/dev/null 2>&1

if [ $? -eq 0 ];
then
    info "$filename Package Download Sucessfully"
else
    info "$filename Package Download Failed"
    exit 1
fi


#Judge if admin account existed or not
adminrecord=$(cat /etc/passwd | grep admin | wc -l)
if [ $adminrecord -lt 1 ];then
    useradd admin
fi



cd $folderpath
unzip $filename
chmod 755 -R /app/server/hadoop-3.3.1
chown -R admin:root /app/server/hadoop-3.3.1
rm -rf $filename




hadooprootenvrecord=$(cat /root/.bashrc | grep HADOOP_HOME | wc -l)
if [ $hadooprootenvrecord -lt 1 ] ;then
    echo 'export HADOOP_HOME=/app/server/hadoop-3.3.1' >> /root/.bashrc
    echo 'export PATH=$PATH:$HADOOP_HOME/bin' >> /root/.bashrc
    echo 'export PATH=$PATH:$HADOOP_HOME/sbin' >> /root/.bashrc
fi





hadoopenvrecord=$(cat /etc/profile | grep HADOOP_HOME | wc -l)
if [ $hadoopenvrecord -lt 1 ] ;then
    echo 'export HADOOP_HOME=/app/server/hadoop-3.3.1' >> /etc/profile
    echo 'export PATH=$PATH:$HADOOP_HOME/bin' >> /etc/profile
    echo 'export PATH=$PATH:$HADOOP_HOME/sbin' >> /etc/profile
fi



server1=centos20
server2=centos21
server3=centos22
server4=centos23
server5=centos24


cat << EOF > /app/server/hadoop-3.3.1/etc/hadoop/core-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
       Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->
<!-- Put site-specific property overrides in this file. -->
<configuration>
    <property>
        <name>hadoop.proxyuser.admin.hosts</name>
        <value>*</value>
    </property>
    <property>
        <name>hadoop.proxyuser.admin.groups</name>
        <value>*</value>
    </property>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://mycluster</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/data/hadoop/</value>
    </property>
    <!-- 设置HDFS web UI用户身份 -->
    <property>
        <name>hadoop.http.staticuser.user</name>
        <value>admin</value>
    </property>
    <property>
    <name>ha.zookeeper.quorum</name>
    <value>$server1:2181,$server2:2181,$server3:2181,$server4:2181,$server5:2181</value>
    </property>
</configuration>
EOF





cat << EOF > /app/server/hadoop-3.3.1/etc/hadoop/hdfs-site.xml
<configuration>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>/data/hadoop/namenode/</value>
    </property>
    <property>
         <name>dfs.datanode.data.dir</name>
        <value>/data/hadoop/datanode/</value>
    </property>
    <property>
        <name>dfs.replication</name>
        <value>3</value>
        <description>副本数配置</description>
    </property>
    <property>
        <name>dfs.nameservices</name>
        <value>mycluster</value>
        <description> 集群名称，此值在接下来的配置中将多次出现务必注意同步修改(core中的相同) </description>
    </property>
    <property>
        <name>dfs.ha.namenodes.mycluster</name>
        <value>nn1,nn2</value>
        <description>所有的namenode列表，此处也只是逻辑名称，非namenode所在的主机名称。</description>
    </property>
    <property>
        <name>dfs.namenode.rpc-address.mycluster.nn1</name>
        <value>$server1:9820</value>
        <description> namenode之间用于RPC通信的地址，value填写namenode所在的主机地址，注意hadoopcluster与nn1要和上文的配置一致</description>
    </property>
    <property>
        <name>dfs.namenode.rpc-address.mycluster.nn2</name>
        <value>$server2:9820</value>
    </property>
    <property>
        <name>dfs.namenode.http-address.mycluster.nn1</name>
        <value>$server1:9870</value>
        <description>namenode的web访问地址，该版本默认端口9870。建议50070</description>
    </property>
    <property>
        <name>dfs.namenode.http-address.mycluster.nn2</name>
        <value>$server2:9870</value>
        <description>namenode的web访问地址，该版本默认端口9870。建议50070</description>
    </property>
    <property>
        <name>dfs.namenode.shared.edits.dir</name>
        <value>qjournal://$server1:8485;$server2:8485;$server3:8485;$server4:8485;$server5:8485/mycluster</value>
        <description>
        journalnode主机地址，最少三台，默认端口8485,格式为 qjournal://jn1:port;jn2:port;jn3:port/${nameservices}
        </description>
    </property>
    <property>
        <name>dfs.client.failover.proxy.provider.mycluster</name>
        <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
        <description>故障时自动切换的实现类，照抄即可</description>
    </property>
    <property>
        <name>dfs.journalnode.edits.dir</name>
        <value>/data/hadoop/journalnode</value>
        <description>namenode日志文件输出路径，即journalnode读取变更的位置</description>
    </property>
    <property>
        <name>dfs.ha.automatic-failover.enabled</name>
        <value>true</value>
        <description>启用自动故障转移</description>
    </property>
    <property>  
        <name>dfs.ha.fencing.methods</name> 
        <value>
        sshfence
        shell(/bin/true)
        </value>
    </property>
    <property>
        <name>dfs.ha.fencing.ssh.private-key-files</name>
        <value>/home/admin/.ssh/id_rsa</value>
    </property>
</configuration>
EOF




cat << EOF > /app/server/hadoop-3.3.1/etc/hadoop/mapred-env.sh 
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

##
## THIS FILE ACTS AS AN OVERRIDE FOR hadoop-env.sh FOR ALL
## WORK DONE BY THE mapred AND RELATED COMMANDS.
##
## Precedence rules:
##
## mapred-env.sh > hadoop-env.sh > hard-coded defaults
##
## MAPRED_xyz > HADOOP_xyz > hard-coded defaults
##

###
# Job History Server specific parameters
###

# Specify the max heapsize for the JobHistoryServer.  If no units are
# given, it will be assumed to be in MB.
# This value will be overridden by an Xmx setting specified in HADOOP_OPTS,
# and/or MAPRED_HISTORYSERVER_OPTS.
# Default is the same as HADOOP_HEAPSIZE_MAX.
#export HADOOP_JOB_HISTORYSERVER_HEAPSIZE=

# Specify the JVM options to be used when starting the HistoryServer.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#export MAPRED_HISTORYSERVER_OPTS=

# Specify the log4j settings for the JobHistoryServer
# Java property: hadoop.root.logger
#export HADOOP_JHS_LOGGER=INFO,RFA
export JAVA_HOME=/app/server/jdk1.8.0_91
EOF





cat << EOF > /app/server/hadoop-3.3.1/etc/hadoop/yarn-site.xml
<?xml version="1.0"?>
<!--
            Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->
<configuration>
    <!-- Site specific YARN configuration properties -->
    <property>
        <name>yarn.nodemanager.resource.memory-mb</name>
        <value>4096</value>
        <discription>每个节点可用内存,默认8192M(8G),这里设置30G</discription>
    </property>
    <property>
        <name>yarn.scheduler.minimum-allocation-mb</name>
        <value>1024</value>
        <discription>单个任务可申请最少内存，默认1024MB</discription>
    </property>
    <property>
        <name>yarn.scheduler.maximum-allocation-mb</name>
        <value>2048</value>
        <discription>单个任务可申请最大内存，默认8192M(8G),这里设置20G</discription>
    </property>
    <property>
        <name>yarn.app.mapreduce.am.resource.mb</name>
        <value>2048</value>
        <discription>默认为1536。MR运行于YARN上时，为AM分配多少内存。默认值通常来说过小，建议设置为2048或4096等较大的值。</discription>
    </property>
    <property>
        <name>yarn.nodemanager.resource.cpu-vcores</name>
        <value>8</value>
        <discription>默认为8。每个节点可分配多少虚拟核给YARN使用，通常设为该节点定义的总虚拟核数即可。</discription>
    </property>
    <property>
        <name>yarn.scheduler.maximum-allocation-vcores</name>
        <value>16</value>
        <discription>分别为1/32，指定RM可以为每个container分配的最小/最大虚拟核数，低 于或高于该限制的核申请，会按最小或最大核数来进行分配。默认值适合 一般集群使用。</discription>
    </property>
    <property>
        <name>yarn.scheduler.minimum-allocation-vcores</name>
        <value>1</value>
        <discription>分别为1/32，指定RM可以为每个container分配的最小/最大虚拟核数，低 于或高于该限制的核申请，会按最小或最大核数来进行分配。默认值适合 一般集>群使用。</discription>
    </property>
    <property>
        <name>yarn.nodemanager.vcores-pcores-ratio</name>
        <value>2</value>
        <discription>每使用一个物理cpu，可以使用的虚拟cpu的比例，默认为2</discription>
    </property>
    <property>
        <name>yarn.nodemanager.vmem-pmem-ratio</name>
        <value>5.2</value>
        <discription>物理内存不足时,使用的虚拟内存，默认是2.1，表示每使用1MB的物理内存，最多可以使用2.1MB的虚拟内存总量。</discription>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.resourcemanager.ha.enabled</name>
        <value>true</value>
    </property>
    <property>
        <name>yarn.resourcemanager.cluster-id</name>
        <value>cluster1</value>
    </property>
    <property>
        <name>yarn.resourcemanager.ha.rm-ids</name>
        <value>rm1,rm2</value>
    </property>
    <property>
        <name>yarn.resourcemanager.hostname.rm1</name>
        <value>$server4</value>
    </property>
    <property>
        <name>yarn.resourcemanager.hostname.rm2</name>
        <value>$server5</value>
    </property>
    <property>
        <name>yarn.resourcemanager.zk-address</name>
        <value>$server1:2181,$server2:2181,$server3:2181,$server4:2181,$server5:2181</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <!-- 是否将对容器实施物理内存限制 -->
    <!-->
             <property>
        <name>yarn.nodemanager.pmem-check-enabled</name>
        <value>false</value></property>
-->
        <!-- 是否将对容器实施虚拟内存限制。 
                 <property><name>yarn.nodemanager.vmem-check-enabled</name><value>false</value></property>
-->
        <!-- 开启日志聚集 -->
        <property>
            <name>yarn.log-aggregation-enable</name>
            <value>true</value>
        </property>
        <!-- 设置yarn历史服务器地址 -->
        <property>
            <name>yarn.log.server.url</name>
            <value>http://$server3:19888/jobhistory/logs</value>
        </property>
        <!-- 保存的时间7天 -->
        <property>
            <name>yarn.log-aggregation.retain-seconds</name>
            <value>604800</value>
        </property>
        <property>
            <name>yarn.resourcemanager.address.rm1</name>
            <value>$server4:8032</value>
        </property>
        <property>
            <name>yarn.resourcemanager.scheduler.address.rm1</name>
            <value>$server4:8030</value>
        </property>
        <property>
            <name>yarn.resourcemanager.webapp.address.rm1</name>
            <value>$server4:8088</value>
        </property>
        <property>
            <name>yarn.resourcemanager.resource-tracker.address.rm1</name>
            <value>$server4:8031</value>
        </property>
        <property>
            <name>yarn.resourcemanager.admin.address.rm1</name>
            <value>$server4:8033</value>
        </property>
        <property>
            <name>yarn.resourcemanager.ha.admin.address.rm1</name>
            <value>$server4:23142</value>
        </property>
        <property>
            <name>yarn.resourcemanager.address.rm2</name>
            <value>$server5:8032</value>
        </property>
        <property>
            <name>yarn.resourcemanager.scheduler.address.rm2</name>
            <value>$server5:8030</value>
        </property>
        <property>
            <name>yarn.resourcemanager.webapp.address.rm2</name>
            <value>$server5:8088</value>
        </property>
        <property>
            <name>yarn.resourcemanager.resource-tracker.address.rm2</name>
            <value>$server5:8031</value>
        </property>
        <property>
            <name>yarn.resourcemanager.admin.address.rm2</name>
            <value>$server5:8033</value>
        </property>
        <property>
            <name>yarn.resourcemanager.ha.admin.address.rm2</name>
            <value>$server5:23142</value>
        </property>
    </configuration>
EOF

su - admin -c "ssh-keygen -t rsa -N '' -f /home/admin/.ssh/id_rsa "
mkdir -p /data/hadoop/
mkdir -p /data/hadoop/namenode/
mkdir -p /data/hadoop/datanode/
mkdir -p /data/hadoop/journalnode
chown -R admin:root /data/hadoop/
chown -R admin:root /data/hadoop/namenode/
chown -R admin:root /data/hadoop/datanode/
chown -R admin:root /data/hadoop/journalnode