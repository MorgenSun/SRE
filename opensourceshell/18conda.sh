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

filename="Anaconda3-2023.09-0-Linux-x86_64.sh"
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
fi

cd $folderpath
chmod +x /app/server/$filename
./Anaconda3-2023.09-0-Linux-x86_64.sh  -b -p /app/server/anaconda3
echo 'export CONDA_HOME=/app/server/anaconda3' >> /etc/profile
echo 'export PATH=$CONDA_HOME/bin:$PATH' >> /etc/profile
source /etc/profile
#添加数据源：例如, 添加清华anaconda镜像：
#conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
#conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
#conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/
#conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
#conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/
# 中科大镜像源
#conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/main/
#conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/free/
#conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/
#conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/msys2/
#conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/bioconda/
#conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/menpo/
#conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/
# 阿里镜像源头
#conda config --add channels https://mirrors.aliyun.com/anaconda/
# 豆瓣镜像源头
#conda config --add channels http://pypi.douban.com/simple/
#conda config --set show_channel_urls yes
conda config --show channels
conda create -n mylab python=3.9
conda init bash



#conda activate mylab
#pip3 install pymysql
#pip3 install flask
#pip3 install requests
#pip3 install redis
#pip3 install elasticsearch5
#pip3 install hdfs
#pip3 install kazoo