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

### Part2
### Part3
### Part4
### Part5
### Part6
### Part7