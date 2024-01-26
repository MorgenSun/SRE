#!/bin/bash

# 定义颜色变量用于Echo警告信息
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

system=$(lsb_release -a 2> /dev/null | grep "Distributor ID:" | cut -d ":" -f2 | tr -d '[:space:]')

if [ "$system" == "CentOS" ]; then
    echo "The system is CentOS."
    hostrecord=$(cat /etc/hosts| grep download | wc -l)
    if [ $hostrecord -lt 1 ]; then
        echo 192.168.31.100 download.mylab.local >> /etc/hosts
    else
        info 'Download.mylab.local record already existed'
    fi

    filename="mysqlserver.zip"
    folderpath="/app/server/"

    if [ -d $folderpath ]; then
        echo $folderpath ready
    else
        mkdir -p $folderpath
        info "$folderpath folder has been created"
    fi

    wget http://download.mylab.local:8888/$filename -P $folderpath >/dev/null 2>&1
    chmod 755 -R /app/server
    chown -R root:root /app/server/$filename

    if [ $? -eq 0 ]; then
        info "$filename Package Download Successfully"
    else
        info "$filename Package Download Failed"
        exit 1
    fi

    cd $folderpath
    unzip $filename
    cd /app/server/mysqlserver
    yum localinstall *  -y
    systemctl start mysqld.service
    systemctl status mysqld.service
    rm -rf mysql*

    cat << EOF > /etc/my.cnf
[mysqld]
character_set_server=utf8
pid-file=/var/lib/mysql/mysqld.pid
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
user=mysql
default-time-zone='+8:00'
symbolic-links=0
port=9918
bind-address=0.0.0.0
log_bin=mysql-bin
server-id=100
expire_logs_days=10
max_binlog_size=100M
sync_binlog=1
binlog_checksum=none
binlog_format=mixed
binlog_cache_size=32M
max_connections=1000
slow_query_log=on
long_query_time=1
skip-host-cache
skip-name-resolve
lower_case_table_names=1
character-set-server=utf8
max_allowed_packet=100M
sql_mode=NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
wait_timeout=3000
interactive_timeout=28800
[mysqld_safe]
default-character-set=utf8
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
[mysql.server]
default-character-set=utf8
[client]
default-character-set=utf8
EOF

    systemctl restart mysqld.service

    defaultpass=$(grep "A temporary password is generated for root@localhost" /var/log/mysqld.log | tail -n 1 | awk '{print $NF}')
    mysqladmin -uroot -p"${defaultpass}"  password Cgnpmiaczqs1!  -P9918
    mysql -uroot -pCgnpmiaczqs1! -P9918 -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.31.%' identified by 'Cgnpmiaczqs1!' with grant option;"
    mysql -uroot -pCgnpmiaczqs1! -P9918 -e 'flush privileges;'
    mysql -uroot -pCgnpmiaczqs1! -P9918 -e 'create database hive;'
    mysql -uroot -pCgnpmiaczqs1! -P9918 -e 'create database nacos;'

elif [ "$system" == "Ubuntu" ]; then
    echo "The system is Ubuntu."
    apt-get -y install mysql-server-5.7
    cat << EOF > /etc/mysql/my.cnf
!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mysql.conf.d/
[mysqld]
character_set_server=utf8
pid-file=/var/lib/mysql/mysqld.pid
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
user=mysql
default-time-zone='+8:00'
symbolic-links=0
port=9918
bind-address=0.0.0.0
log_bin=mysql-bin
server-id=100
expire_logs_days=10
max_binlog_size=100M
sync_binlog=1
binlog_checksum=none
binlog_format=mixed
binlog_cache_size=32M
max_connections=1000
slow_query_log=on
long_query_time=1
skip-host-cache
skip-name-resolve
lower_case_table_names=1
character-set-server=utf8
max_allowed_packet=100M
sql_mode=NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
wait_timeout=3000
interactive_timeout=28800
[mysqld_safe]
default-character-set=utf8
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
[mysql.server]
default-character-set=utf8
[client]
default-character-set=utf8
EOF

    systemctl enable mysql && systemctl start mysql
    mysql -e -P9918 'alter user root@'localhost' identified with mysql_native_password by "Cgnpmiaczqs1!";'
    mysql -uroot -P9918 -pCgnpmiaczqs1! -e 'flush privileges;'
    mysql -uroot -P9918 -pCgnpmiaczqs1! -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.31.%' identified by 'Cgnpmiaczqs1!' with grant option;"
    mysql -uroot -P9918 -pCgnpmiaczqs1! -e 'create database nacos;'
    mysql -uroot -P9918 -pCgnpmiaczqs1! -e 'create database hive;'

else
    echo "Unknown distribution."
fi
