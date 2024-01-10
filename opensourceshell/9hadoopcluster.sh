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




for i in {20..24};do  ssh centos$i "su admin -c 'hdfs --daemon start journalnode'";echo centos$i journalnode starting done;done && \
info 'centos20 namenode start to formant' && \
ssh centos20 "su admin -c 'hdfs namenode -format'" && \
info 'centos20 namenode start ' && \
ssh centos20 "su admin -c 'hdfs --daemon start namenode'" && \
info 'centos21 standby namenode start to get active node data' && \
ssh centos21 "su admin -c 'hdfs namenode -bootstrapStandby'"  && \
info 'centos20 ZKFC Point Start to format' && \
ssh centos20 "su admin -c 'hdfs zkfc -formatZK'" && \
info 'centos20 zkfc node start' && \
ssh centos20 "su admin -c 'hdfs --daemon start zkfc'" && \
info 'centos21 zkfc node start' && \
ssh centos21 "su admin -c 'hdfs --daemon start zkfc'" && \
info 'centos21 namenode start' && \
ssh centos21 "su admin -c 'hdfs --daemon start namenode'"  && \
info 'centos20 datanode start' && \
ssh centos20 "su admin -c 'hdfs --daemon start datanode'" && \
info 'centos21 datanode start' && \
ssh centos21 "su admin -c 'hdfs --daemon start datanode'" && \
info 'centos22 datanode start' && \
ssh centos22 "su admin -c 'hdfs --daemon start datanode'" && \
info 'centos23 datanode start' && \
ssh centos23 "su admin -c 'hdfs --daemon start datanode'" && \
info 'centos24 datanode start' && \
ssh centos24 "su admin -c 'hdfs --daemon start datanode'" && \
info 'centos23 resourcemanager start' && \
ssh centos23 "su admin -c 'yarn --daemon start resourcemanager'" && \
info 'centos24 resourcemanager start' && \
ssh centos24 "su admin -c 'yarn --daemon start resourcemanager'" && \
info 'centos20 nodemanager start' && \
ssh centos20 "su admin -c 'yarn --daemon start nodemanager'" && \
info 'centos21 nodemanager start' && \
ssh centos21 "su admin -c 'yarn --daemon start nodemanager'" && \
info 'centos22 nodemanager start' && \
ssh centos22 "su admin -c 'yarn --daemon start nodemanager'" && \
info 'centos23 nodemanager start' && \
ssh centos23 "su admin -c 'yarn --daemon start nodemanager'" && \
info 'centos24 nodemanager start' && \
ssh centos24 "su admin -c 'yarn --daemon start nodemanager'"


#centos20/centos21 hdfs haadmin -getServiceState nn1
#centos20/centos21 hdfs haadmin -getServiceState nn2
#hdfs haadmin -transitionToActive nn206
echo 'start to check jps for every hadoop node'
for i in {20..24};do  info ~~~~~~~~~centos$i~~~~~~~ ;ssh root@centos$i jps;done
echo 'Checking two namenode status'
for i in nn1  nn2 ;do ssh centos24 "su admin -c 'hdfs haadmin -getServiceState $i'";done