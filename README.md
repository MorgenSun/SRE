Project SRE
项目是为了分享个人在开源运维时的一些一键部署脚本

### 前提条件
所有的脚本都是自动下载安装包并部署 下载download.mylab.local域名8888端口下载 所以请确保在你的域名download.mylab.local对应的Nginx服务器配置中有如下一段配置:

    server {
        listen       8888;
        server_name  download.mylab.local;
        root         /lab;
        include /etc/nginx/default.d/*.conf;
        error_page 404 /404.html;
        location = /404.html {
        }
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
生成后 nginx -s reload 或者systemctl restart nginx . 在/lab下放入对应的文件后即可 成功运行如下命令:

wget http://download.mylab.local:8888/$filename -P $folderpath >/dev/null 2>&1

其次所有涉及的文件均放在Google Drive上 地址如下: 

https://drive.google.com/drive/folders/1ZFh8Z3BQ8sfXTvXb1M6ujb6BN06nJ8my?usp=drive_link

### 项目介绍
项目分为 四部分 内容和用途分别如下:

allshell 作为KVM物理机层面初始化脚本<br>
目录如下:<br>
initall.sh<br>
nginx.sh<br>
revertall.sh<br>
scpai.sh<br>
scphosts.sh<br>
scpshell.sh<br>
start5.sh
start5withminio.sh
start6.sh
start7-12.sh
startrest.sh


opensourceDockerDeploy 作为 Docker容器化部署 来源于Docker 、 Docker-compose 社区最新版本均适用
(待更新)


opensourceshell 作为开源运维一键部署脚本 内容如下:
10mysql.sh<br>
11hbase.sh<br>
12sparkonyarn.sh<br>
13sparkstandalone.sh<br>
14hive.sh<br>
15flink.sh<br>
16maven.sh<br>
17tomcat9.sh<br>
18conda.sh<br>
19nacos.sh<br>
1java本地安装包安装.sh<br>
20Jenkins.sh<br>
21redisstandalone.sh<br>
22dockerandcompose.sh<br>
23nginxproxymanager.sh<br>
24k8sinstall.sh<br>
25jdk17.sh<br>
26haproxy.sh<br>
27keepalived.sh<br>
28gitlab.sh<br>
29mysqlclient.sh<br>
2zookeeper部署脚本.sh<br>
30miniocluster.sh<br>
3kafka部署脚本.sh<br>
4ES.sh<br>
5rediscluster.sh<br>
6计算耗时<br>
8Hadoop.sh<br>
9hadoopcluster.sh<br>
runall.sh<br>


