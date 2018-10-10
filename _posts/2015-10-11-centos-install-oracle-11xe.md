---
title: 在CentOS 7虚拟机上安装Oracle XE数据库
date: 2015/10/11 09:55:24
categories: 
- Oracle
- 学习
tags: 
- Oracle
- CentOS
- 数据库
---

1. 自行使用虚拟机安装`CentOS-7-x86_64-DVD-1804.iso`。

2. 下载`适用于 Linux x64 的 Oracle Database 快捷版 11g 第 2 版`  
[https://www.oracle.com/technetwork/cn/database/database-technologies/express-edition/downloads/index.html](https://www.oracle.com/technetwork/cn/database/database-technologies/express-edition/downloads/index.html)

3. 将`oracle-xe-11.2.0-1.0.x86_64.rpm.zip`解压后，得到`Disk1`文件夹， 使用SFTP传到CentOS 7中的/root根目录下。
![]({{ site.url }}/assets/blogImg/2015/centos_oracle_xe/centos_oracle_xe_01.png)
<!--more-->
4. SSH连接到CentOS，安装依赖。
```shell
yum install libaio libaio-devel bc -y
```
![]({{ site.url }}/assets/blogImg/2015/centos_oracle_xe/centos_oracle_xe_02.png)

5. 分配SWAP空间，依次执行以下命令
```shell
su - root
dd if=/dev/zero of=/swapfile bs=1024 count=1048576
mkswap /swapfile
swapon /swapfile
cp /etc/fstab /etc/fstab.backup_$(date +%N)
echo '/swapfile swap swap defaults 0 0' /etc/fstab
chown root:root /swapfile
chmod 0600 /swapfile
swapon -a
swapon -s
```

6. 可以用`free -m`查看Swap大小， 确保大于2048M就可以了。
![]({{ site.url }}/assets/blogImg/2015/centos_oracle_xe/centos_oracle_xe_03.png)

7. 安装`oracle-xe-11.2.0-1.0.x86_64.rpm`
```shell
cd Disk1/
rpm -ivh oracle-xe-11.2.0-1.0.x86_64.rpm
```
![]({{ site.url }}/assets/blogImg/2015/centos_oracle_xe/centos_oracle_xe_04.png)

8. 配置数据库，分别配置HTTP端口8080，数据库监听端口1521，数据库SYS和SYSTEM密码，设置Oracle开启自启。
```shell
/etc/init.d/oracle-xe configure
```
![]({{ site.url }}/assets/blogImg/2015/centos_oracle_xe/centos_oracle_xe_05.png)

9. 配置环境变量
```shell
vi /etc/profile
```
加入
```shell
# Oracle Settings
TMP=/tmp; export TMP
TMPDIR=$TMP; export TMPDIR
ORACLE_BASE=/u01/app/oracle; export ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/product/11.2.0/xe; export ORACLE_HOME
ORACLE_SID=XE; export ORACLE_SID
ORACLE_TERM=xterm; export ORACLE_TERM
PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH
TNS_ADMIN=$ORACLE_HOME/network/admin
LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH
if [ $USER = "oracle" ]; then
  if [ $SHELL = "/bin/ksh" ]; then
    ulimit -p 16384
    ulimit -n 65536
  else
    ulimit -u 16384 -n 65536
  fi
fi
```
更新环境变量
```shell
source /etc/profile
```
查看是否修改成功
```shell
echo $ORACLE_BASE
```
得到`/u01/app/oracle`就是oracle的安装目录

10. 添加权限
```shell
cd /u01/app/oracle/product/11.2.0/xe/bin
chmod +s oracle
```

11. 关闭CentOS防火墙  
```shell
# 查看防火墙状态
firewall-cmd --state 
# 停止防火墙状态
systemctl stop firewalld.service  
# 禁止防火墙状态开机启动  
systemctl disable firewalld.service  
```

11. 测试是否连得上Oracle数据库  
```shell
su - oracle 
sqlplus /nolog
connect as sysdba
# 用户名sys，密码是刚才设置的密码
```  
出现`Connected.`表示连接成功。

# 参考文章
1. [Linux下安装Oracle Database 11g Express Edition](https://blog.csdn.net/hqs_1992/article/details/41895389)
2. [Centos7安装Oracle-xe](https://www.jianshu.com/p/58919daadf75?utm_source=oschina-app)
3. [CentOS7 安装 oracleXE（快捷版）教程](https://blog.csdn.net/qq_26820293/article/details/78566063)