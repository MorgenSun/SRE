#!/bin/bash

# 定义脚本数组
scripts=(
    "1java本地安装包安装.sh"
    "2zookeeper部署脚本.sh"
    "3kafka部署脚本.sh"
    "4ES.sh"
    "5rediscluster.sh"
    "6计算耗时"
    "8Hadoop.sh"
    "9hadoopcluster.sh"
    "10mysql.sh"
    "11hbase.sh"
    "12sparkonyarn.sh"
    "13sparkstandalone.sh"
    "14hive.sh"
    "15flink.sh"
    "16maven.sh"
    "17tomcat9.sh"
    "18conda.sh"
    "19nacos.sh"
    "20Jenkins.sh"
    "21redisstandalone.sh"
    "22dockerandcompose.sh"
    "23nginxproxymanager.sh"
)

# 显示脚本列表
echo "请选择要运行的脚本："
for script in "${scripts[@]}"; do
    echo "$script"
done

# 读取用户输入
read -p "请输入脚本编号或关键字: " input

# 检查输入是否为数字
if [[ $input =~ ^[0-9]+$ ]]; then
    # 运行对应编号的脚本
    if ((input > 0 && input <= ${#scripts[@]})); then
        echo "运行脚本: ${scripts[$input-1]}"
        # 调用脚本
        # ./path/to/${scripts[$input-1]}
    else
        echo "无效的编号"
    fi
else
    # 搜索并确认脚本
    for script in "${scripts[@]}"; do
        if [[ $script == *$input* ]]; then
            read -p "是否运行脚本 $script? [y/N]: " confirm
            if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
                echo "运行脚本: $script"
                # 调用脚本
                # ./path/to/$script
                break
            fi
        fi
    done
fi
