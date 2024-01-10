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

filename="apache-hive-3.1.3-bin.tar.gz"
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

echo 'export HIVE_HOME=/app/server/apache-hive-3.1.3-bin/
export PATH=$HIVE_HOME/bin:$PATH' >> /etc/profile

source /etc/profile


cd $folderpath
tar -zxvf $filename
rm -rf $filename
cd /app/server/apache-hive-3.1.3-bin/conf
touch hive-env.sh
touch hive-site.xml
: > /app/server/apache-hive-3.1.3-bin/conf/hive-site.xml
echo 'export JAVA_HOME=/app/server/jdk1.8.0_91
export HIVE_HOME=/app/server/apache-hive-3.1.3-bin
export HADOOP_HOME=/app/server/hadoop-3.3.1/' >> /app/server/apache-hive-3.1.3-bin/conf/hive-env.sh



cat << EOF > /app/server/apache-hive-3.1.3-bin/conf/hive-site.xml
<configuration>
<property>
  <name>hive.metastore.local</name>
  <value>false</value>
</property>
<property>
  <name>hive.metastore.warehouse.dir</name>
  <value>/data/hive_warehouse</value>
</property>
<property>
    <name>hive.metastore.uris</name>
    <value>thrift://192.168.31.23:9083,thrift://192.168.31.24:9083</value>
</property>
<property>
  <name>hive.server2.thrift.max.worker.threads</name>
  <value>2000</value>
</property>
<property>
    <name>javax.jdo.option.ConnectionURL</name>
    <value>jdbc:mysql://192.168.31.25:3306/hive?useSSL=false</value>
</property>
<property>
    <name>javax.jdo.option.ConnectionDriverName</name>
    <value>com.mysql.jdbc.Driver</value>
</property>
<property>
    <name>javax.jdo.option.ConnectionUserName</name>
    <value>root</value>
</property>
<property>
    <name>javax.jdo.option.ConnectionPassword</name>
    <value>Cgnpmiaczqs1!</value>
</property>
<property>
    <name>hive.querylog.location</name>
    <value>/data/hive_repo/querylog</value>
</property>
<property>
    <name>hive.exec.local.scratchdir</name>
    <value>/data/hive_repo/scratchdir</value>
</property>
<property>
    <name>hive.downloaded.resources.dir</name>
    <value>/data/hive_repo/resources</value>
</property>
<property>
    <name>hive.metastore.schema.verification</name>
    <value>false</value>
</property>
</configuration>
EOF

mkdir -p /data/hive_repo
mkdir -p /data/querylog
mkdir -p /data/hive_repo/scratchdir
mkdir -p /data/hive_repo/resources
mkdir -p  /data/hive_warehouse
chown -R admin:root /data/hive_warehouse
chown -R admin:root /data/hive_repo
chown -R admin:root /data/querylog
chmod 755 -R /data/hive_repo
chmod 755 -R /data/querylog
chmod 755 -R /data/hive_warehouse

mkdir -p  /app/server/apache-hive-3.1.3-bin/log
chown -R admin:root /app/server/apache-hive-3.1.3-bin/log
chmod 755 -R /app/server/apache-hive-3.1.3-bin/log


wget http://download.mylab.local:8888/mysql-connector-java-5.1.49-bin.jar -P /app/server/apache-hive-3.1.3-bin/lib
wget http://download.mylab.local:8888/mysql-connector-java-5.1.49.jar -P /app/server/apache-hive-3.1.3-bin/lib
chown -R admin:root /app/server/apache-hive-3.1.3-bin/
chmod 755 -R /app/server/apache-hive-3.1.3-bin/

wget http://download.mylab.local:8888/mysqlclient.zip -P /app/server/
unzip /app/server/mysqlclient.zip
cd mysqlclient
yum install * -y
rm -rf /app/server/mysqlclient
rm -rf /app/server/mysqlclient.zip


# MySQL credentials and database name
MYSQL_USER="root"
MYSQL_PASS='Cgnpmiaczqs1!'
DATABASE_TO_CHECK="hive"

# Command to check if the database exists
DB_EXISTS=$(mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" -h 192.168.31.25 -e "SHOW DATABASES LIKE '$DATABASE_TO_CHECK';")

# Check for the database
if [ "$DB_EXISTS" == "" ]; then
    echo "The database '$DATABASE_TO_CHECK' does not exist."
else
    echo "The database '$DATABASE_TO_CHECK' exists."

    # Command to check for any tables in the database
    TABLES_EXIST=$(mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" -h 192.168.31.25 -e "USE $DATABASE_TO_CHECK; SHOW TABLES;")

    # Remove the heading "Tables_in_<database>"
    TABLES_EXIST=$(echo "$TABLES_EXIST" | sed '1d')

    # Check for tables
    if [ "$TABLES_EXIST" == "" ]; then
        alert "There are no tables in the database '$DATABASE_TO_CHECK'."
        su - admin -c '/app/server/apache-hive-3.1.3-bin/bin/schematool -dbType mysql -initSchema'
        info 'Hive DB initial done'
    else
        echo "The database '$DATABASE_TO_CHECK' has the following tables:"
        echo "$TABLES_EXIST"
        alert "Nothing else to do"
    fi
fi



# 获取主机名
hostname=$(hostname)

# 使用case语句进行判断
case $hostname in
  centos20)
    su - admin -c 'nohup /app/server/apache-hive-3.1.3-bin/bin/hiveserver2  2>&1 >> /app/server/apache-hive-3.1.3-bin/log/hiveserver2.log &'
    ;;
  centos21)
    su - admin -c 'nohup /app/server/apache-hive-3.1.3-bin/bin/hiveserver2  2>&1 >> /app/server/apache-hive-3.1.3-bin/log/hiveserver2.log &'
    ;;
  centos22)
    su - admin -c 'nohup /app/server/apache-hive-3.1.3-bin/bin/hiveserver2  2>&1 >> /app/server/apache-hive-3.1.3-bin/log/hiveserver2.log &'
    ;;
  *)
    su - admin -c 'nohup /app/server/apache-hive-3.1.3-bin/bin/hive --service metastore  2>&1 >> /app/server/apache-hive-3.1.3-bin/log/metastore.log  &'
    alert 'Metastore client assigned . Installation done !'
    ;;
esac




