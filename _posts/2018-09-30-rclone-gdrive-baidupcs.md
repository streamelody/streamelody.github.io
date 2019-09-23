---
title: GCP上使用rclone挂载GoogleDrive+百度盘下载
date: 2018/09/30 20:11:24
categories: 
- 博客
- VPS
tags: 
- GCP
- rclone
- GoogleDrive
---

# 配置 Google API
<br/>
① 启用[Google API](https://console.developers.google.com/apis/api/drive.googleapis.com/overview)。
![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/rclone_gdrive/rclone_gdrive_001.png)

② 再创建一个[OAuth 客户端 ID](https://console.developers.google.com/apis/credentials/oauthclient)，然后配置`OAuth同意屏幕`。
<!--more-->
![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/rclone_gdrive/rclone_gdrive_002.png)
![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/rclone_gdrive/rclone_gdrive_003.png)

③ 应用类型选择`其他(Other)`，名称自己填。
![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/rclone_gdrive/rclone_gdrive_004.png)

④ 记录获取的`客户端 ID`和`客户端密钥`。
```bash
这是您的客户端 ID
578879908563-1geod9pt0qha5ica9s6n6kvr4upb0j9q.apps.googleusercontent.com
这是您的客户端密钥
DTcYUH1q0aHIjsll-8PfEmH_
```
![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/rclone_gdrive/rclone_gdrive_005.png)

# 安装并配置 Rclone
<br/>
① GCP 使用`Ubuntu 16.04 LTS`，安装 rclone。
```bash
wget https://www.moerats.com/usr/shell/rclone_debian.sh && bash rclone_debian.sh
```

② 初始化配置。
```bash
rclone config
```

③ 第一步选择`n`，然后回车输入一个名字`Rclone`。
```bash
n) New remote
s) Set configuration password
q) Quit config
n/s/q>n
```

④ 选择挂载的类型。
```
12 / Google Drive
   \ "drive"
13 / Hubic
   \ "hubic"
Storage> 12 
```

⑤ 输入上一步申请的`客户端 id`和`客户端密钥`。
```
Google Application Client Id
Leave blank normally.
Enter a string value. Press Enter for the default ("").
client_id> 
Google Application Client Secret
Leave blank normally.
Enter a string value. Press Enter for the default ("").
client_secret> 
```

⑥ 回车默认，直到`Use auto config?`，选择`n`。
```
Use auto config?
* Say Y if not sure
* Say N if you are working on a remote or headless machine or Y didn't work
y) Yes
n) No
y/n> n
```

⑦ 获得`GoogleDrive`的授权登录地址，登陆并允许，回到终端输入授权码，回车。
```
If your browser doesn't open automatically go to the following
link: https://accounts.google.com/o/oauth2/auth?access_type=
offline&client_id=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Log in and authorize rclone for access
Enter verification code>

```

![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/rclone_gdrive/rclone_gdrive_006.png)

⑧ 接下来默认选`n`，最后选择`q`退出。
```bash
e) Edit existing remote
n) New remote
d) Delete remote
r) Rename remote
c) Copy remote
s) Set configuration password
q) Quit config
e/n/d/r/c/s/q>q
```

# 挂载Google Drive
<br/>
① 创建挂载目录。
```bash
mkdir /root/GoogleDrive
```

② 输入挂载命令。
```bash
# Rclone 为 Rclone 的配置名称
# :后为网盘里的文件夹路径，如果你要挂载整个网盘，可以不用填
# /root/GoogleDrive 为本地服务器上的挂载文件夹
rclone mount Rclone: /root/GoogleDrive \
--daemon \ 
--umask 0000 \
--default-permissions \
--allow-non-empty \
--allow-other \
--transfers 4 \
--buffer-size 32M \
--low-level-retries 200 \
--dir-cache-time 12h \
--vfs-read-chunk-size 32M \
--vfs-read-chunk-size-limit 1G 
```

③ 查看挂载状态。
```
df -Th
```
![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/rclone_gdrive/rclone_gdrive_007.png)

# Rclone 使用命令
> `Rclone`配置位置`~/.config/rclone/rclone.conf`，多台电脑通用，不需要重复配置。

```shell
# copy 复制命令
rclone copy -v --stats 5s Rclone:temp RcloneDemo:temp -P

# sync 同步命令 一般不使用
# 同步之前检查
rclone --size-only --dry-run sync Rclone:temp RcloneDemo:temp -P

# 同步
rclone --size-only sync Rclone:temp RcloneDemo:temp -P

# 同步后确认是否有不同 
rclone --size-only --stats 5s check Rclone:temp RcloneDemo:temp -P
```

# 百度盘下载相关

```shell
# 安装 baidupcs-web
wget -N --no-check-certificate "https://raw.githubusercontent.com/user1121114685/baidupcsweb/master/BDW.sh" && chmod +x BDW.sh && bash BDW.sh

# 在线获取 BDUSS 工具。
# http://tool.cccyun.cc/tool/bduss/index2.html

# 设置 swap
wget https://www.moerats.com/usr/shell/swap.sh && bash swap.sh
# 然后根据选项进行操作，记得添加`swap`的时候填写纯数字，默认单位为`M`。
# 查看内存状况
free -m

# 安装 unrar
sudo apt-get install rar
sudo apt-get install unrar

# 使用命令 
rar x filename.rar
unzip filename.zip
tar xvf filename.tar

# Ubuntu 终端显示?乱码
sudo locale-gen zh_CN.UTF-8

# 使用 tree 命令显示文件
apt-get install tree
tree -N

# 模糊搜索
sudo find / -name '*tomcat*'

# screen 相关使用
apt-get install screen
# screen 进入页面
# screen -ls 显示列表 
# screen -r 数字名 连接对应窗口
# screen -X -S 数字名 quit 删除对应窗口
# control + a + d 退出窗口

# connect to host 23.95.70.239 port 22: Connection refused 解决方法
# 查看 sshd 服务失败的原因
/usr/sbin/sshd -T
# 查找到原因为 Missing privilege separation directory: /var/run/sshd
# 以下是解决方案
mount|grep /var
ls -al /var/run/|grep ssh; echo $?
sudo mkdir /var/run/sshd
sudo /etc/init.d/ssh restart
```

# Aria2 离线下载搭建

```shell
# 安装 Aria2
# 默认密匙：doub.io
# 默认下载地址：/usr/local/caddy/www/file
wget -N --no-check-certificate https://www.moerats.com/usr/shell/Aria2/aria2.sh && chmod +x aria2.sh && bash aria2.sh

# 安装 Aria2 WebUI前端
wget -N --no-check-certificate https://www.moerats.com/usr/shell/Caddy/caddy_install.sh && chmod +x caddy_install.sh && bash caddy_install.sh install http.filemanager

# 新建并进入文件夹
mkdir /usr/local/caddy/www && mkdir /usr/local/caddy/www/aria2 && mkdir /usr/local/caddy/www/aria2/Download
cd /usr/local/caddy/www/aria2
 
# 先安装 unzip 依赖（解压ZIP）。
# CentOS 系统：
yum install unzip -y
# Debian/Ubuntu 系统：
apt-get install unzip -y

# 然后下载前端文件
wget -N --no-check-certificate https://github.com/ziahamza/webui-aria2/archive/master.zip
unzip master.zip  
mv webui-aria2-master/docs/* .
rm -rf webui-aria2-master/
rm -rf master.zip  
# 赋予文件夹权限
chmod -R 755 /usr/local/caddy/www/aria2


#配置ip访问，以下全部内容是一个整体，是一个命令，全部复制粘贴到SSH软件中并一起执行！
echo ":80 {
 root /usr/local/caddy/www/aria2
 timeouts none
 gzip
}" > /usr/local/caddy/Caddyfile

#运行
/etc/init.d/caddy start
```

# 参考文章

1. [在Debian/Ubuntu上使用rclone挂载Google Drive网盘](https://www.moerats.com/archives/481/)

2. [使用Plexdrive/Rclone+Google Drive搭建无限容量的媒体库，适用于Plex/Emby/Jellyfin等](https://www.moerats.com/archives/870/)

3. [解决Rclone挂载Google Drive时上传失败和内存占用高等问题](https://www.moerats.com/archives/877/)

4. [baidupcs-web的一键脚本(ubuntu/debian/centos)](https://github.com/liuzhuoling2011/baidupcs-web/issues/65)

5. [Linux VPS一键添加/删除Swap虚拟内存](https://www.moerats.com/archives/722/)

6. [在Debian/Ubuntu上使用rclone挂载OneDrive网盘](https://www.moerats.com/archives/491/)

7. [百度网盘PCS的WEB版本的linux一键脚本](https://github.com/user1121114685/baidupcsweb)

8. [使用Aria2+AriaNG+FileManager来进行离线BT下载及在线播放](https://www.moerats.com/archives/401/)

9.  [一个支持 离线下载/BT/磁力链接 的Aria2在线管理面板 —— Aria2 WebUI](https://doubibackup.com/ouiwm7ss-3.html)

