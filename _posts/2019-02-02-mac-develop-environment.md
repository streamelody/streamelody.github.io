---
title: Mac 上开发环境搭建笔记
date: 2019/02/02 23:37:05
categories: 
- 编程
- 随笔
tags: 
- Mac
- 开发环境
---

# Mac 使用小技巧

```shell
# 配置 PD 虚拟机下，走宿主机 SS 代理
宿主机 SS 修改本地 Socks5 监听地址：0.0.0.0
虚拟机网络设置为：桥接
虚拟机的代理为 Socks5 代理：宿主机ip:1086

# 配置终端走代理，返回数据表示成功
export {http,https}_proxy=socks5://0.0.0.0:1086
curl https://www.google.com 

# 显示隐藏文件和隐藏文件
⌘ + ⇧ + .
chflags hidden 文件路径

# Unicode 十六进制输入，⌥ + 对应编码即可
⌘/Command: 2318     ⌥/Alt/Option: 2325  ⇧/Shift: 21E7   ⌃/Control: 2303  
⏎/Enter: 23ce       ⌫/Delete: 232B      ⎋/ESC: 238B    
⇪/Capslock: 21ea    ⇥/Tab: 8677         /Apple Logo: ⌥ + ⇧ + K 

# 截图去掉阴影效果
defaults write com.apple.screencapture disable-shadow -bool TRUE
Killall SystemUIServer

# 关闭 SIP 
⌘ + R 进入恢复模式，终端使用命令 csrutil disable

# 允许任何来源
sudo spctl --master-disable

# Surge for Mac 相关配置
# 安装 v2ray-core 和 shadowsocks-libev
brew tap v2ray/v2ray
brew install v2ray-core
brew install shadowsocks-libev

# 安装完成后 v2ray 的位置
/usr/local/bin/v2ray

# 安装完成后 ss-local 的位置
/usr/local/bin/ss-local

# surge.conf 配置文件
External-SSR = external, exec = "/usr/local/bin/ss-local", args = "-c", args = "/Users/shuangyeying/BWG_CN2_SSR.json", local-port = 19522

External_V2Ray = external, exec = "/usr/local/bin/v2ray", local-port = 19829, args = "--config=/Users/shuangyeying/BWG_CN2_V2Ray.json"
```
<!--more-->

# 安装 HomeBrew

```shell
# 安装 Command Line Tools
# https://developer.apple.com/download/more/

# https://brew.sh/index_zh-cn.html
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# 配置 HomeBrew 不自动更新
vim ~/.bash_profile
export HOMEBREW_NO_AUTO_UPDATE=true
source ~/.bash_profile
```

# 安装 sshpass

```shell
# 安装后可以用 sshpass -p 'PassWord' ssh -p [port] username@host 登陆 ssh。
brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
```

# 安装 telnet

```shell
brew install telnet
```

# 安装 adb

```shell
brew tap caskroom/versions
brew cask install android-platform-tools
```
# 安装 Packet Sender

```shell
brew cask install packetsender
```

# 安装 FFmpeg

```shell
# 使用格式 ffmpeg -i input.mov -crf 20 output.mp4
brew install ffmpeg

# 一些使用方法

# 查看视频文件信息
ffmpeg -i input.mp4
# 抽取音频
ffmpeg -i input.mp4 -acodec copy -vn output.m4a
# 抽取视频
ffmpeg -i input.mp4 -vcodec copy -an output.mp4
# 音视频合成
ffmpeg -i output.mp4 -i out.m4a -vcodec copy -acodec copy finish.mp4

# 去黑边
# 获取裁剪参数
ffmpeg -ss 90 -i input.mp4 -vframes 10 -vf cropdetect -f null -
# 使用 ffplay
ffplay -vf crop=1280:720:0:0 input.mp4
# 使用裁剪滤镜重新编码
ffmpeg -i input.mp4 -vf crop=2864:1616:8:92 -c:a copy output.mp4

```

# 安装 Python3

```shell
brew install python3
python3 --version
```

# 安装 Git

```shell
brew install git

# 配置用户名、邮箱
git config --global user.name "your_name" 
git config --global user.email "your_email@youremail.com"

# 查看 Git 配置信息
git config --list

# 生成密钥。在 ~/.ssh 下，id_rsa 是私钥，id_rsa.pub 是公钥。
ssh-keygen -t rsa -C "your_email@youremail.com"

# 设置 Git 为大小写敏感
git init 
git config core.ignorecase false

# 创建一个新仓库
git clone ssh://git@192.168.2.232:10022/streamelody/practice.git
cd practice
touch README.md
git add README.md
git commit -m "add README"
git push -u origin master

# 已经存在一个文件夹
cd folder
git init 
git remote add origin ssh://git@192.168.2.232:10022/streamelody/practice.git
git add .
git commit -m "Initail commit"
git push -u origin master

# 已经存在一个仓库
cd repository
git remote rename origin old-origin
git remote add git remote add origin ssh://git@192.168.2.232:10022/streamelody/practice.git
git push -u origin --all
git push -u origin --tags
```

# 安装 Docker

```shell
# 安装 Docker 
brew cask install docker

# 安装 kitematic
brew cask install docker kitematic

# 备份和恢复容器

# 查看正在运行的 Docker 容器
docker container ls
# 生成 Docker 容器快照
docker commit -p 97db03785c93 container-backup
# 查看 Docker 镜像
docker images

# 将镜像作为 tar 包备份到本地
docker save -o ~/container-backup.tar container-backup
# 加载 Docker 本地镜像
docker load -i ~/container-backup.tar
# 查看 Docker 镜像
docker images
# 运行 Docker 镜像
docker run -d -p 80:80 container-backup

# 将镜像上传到 Docker Hub
docker login
docker tag 97db03785c93 streamelody/container-backup:test
docker push streamelody/container-backup

# 恢复容器
docker pull streamelody/container-backup:test
```


# 使用 Docker 搭建 Gitlab

```shell
# pull gitlab 镜像
docker search gitlab
sudo docker pull gitlab/gitlab-ce:latest

# ~/.docker/gitlab 下分别创建 config，logs，data 目录
mkdir -p ~/.docker/gitlab/config
mkdir -p ~/.docker/gitlab/logs
mkdir -p ~/.docker/gitlab/data

# 查询本机 ip，在 gitlab 配置文件里指定 external_url 和 gitlab_shell_ssh_port
ifconfig
vim ~/.docker/gitlab/config/gitlab.rb
external_url 'http://192.168.2.232'
gitlab_rails['gitlab_shell_ssh_port'] = 10022

# 创建 docker 中的网络
docker network create gitlab_net

# 启动 Gitlab 容器
docker run --name='gitlab' -d \
       --net=gitlab_net \
       --publish 10022:22 --publish 1443:443 --publish 18080:80 \
       --restart always \
       --volume ~/.docker/gitlab/config:/etc/gitlab \
       --volume ~/.docker/gitlab/logs:/var/log/gitlab \
       --volume ~/.docker/gitlab/data:/var/opt/gitlab \
       gitlab/gitlab-ce:latest
       
# 启动时间较久（大约2分钟）， STATUS 显示 healthy 表示启动完成
docker container ls

# 查询本机 ip， 浏览器使用 ip:18080 访问

# 登陆后 Settings -> SSH Keys，添加 SSH Keys
cat ~/.ssh/id_rsa.pub

# 常用命令
docker restart gitlab
docker container stop gitlab
docker container rm gitlab
```

# 安装 jekyll

```shell
gem -v 
sudo gem update --system
sudo gem install -n /usr/local/bin jekyll
# 安装其他的依赖
sudo gem install -n /usr/local/bin [dependencies]

# 查看 jekyll 版本
jekyll -v

# 本地预览
cd blog_dir
jekyll serve
```

# 安装 JDK

```shell
# 安装最新版 Oracle JDK
brew cask install java

# [备用] 安装 Adopt Open JDK 8
brew tap AdoptOpenJDK/openjdk
brew cask install adoptopenjdk/openjdk/adoptopenjdk8
# 配置环境变量
vim ~/.bash_profile
export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home
source ~/.bash_profile

# [推荐] 安装 Oracle JDK 1.8.0_202-b08
brew cask install https://streamelody.github.io/assets/attachment/java8.rb
```

# 安装 redis

```shell
# 安装后配置文件的路径： /usr/local/etc/redis.conf
brew install redis

# 查看安装路径
brew list redis

# 添加至开机启动项（可选）
ln -f /usr/local/Cellar/redis/5.0.3/homebrew.mxcl.redis.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist

# 启动 
redis-server
```

# 安装 MySQL 5.5

```shell
# 使用 brew 安装
brew install cmake
brew install mysql@5.5

# 配置环境变量
vim ~/.bash_profile
export PATH="/usr/local/opt/mysql@5.5/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/mysql@5.5/lib"
export CPPFLAGS="-I/usr/local/opt/mysql@5.5/include"
source ~/.bash_profile 

# 启动mysql服务
brew services start mysql@5.5

# 进入mysql
mysql -uroot

# 修改密码
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('你的新密码’);

# 重设密码
mysql_secure_installation
```

# 使用 Docker 安装 MySQL 5.5

```shell
# 拉取镜像
docker pull mysql:5.5
# 创建数据库的本地文件夹、
mkdir -p ~/.docker/mysql/data
# 启动容器     
docker run --name='mysql' -d \
       --publish 3307:3306 \
       --restart always \
       -e MYSQL_ROOT_PASSWORD=root \
       --volume ~/.docker/mysql/data:/var/lib/mysql \
       mysql:5.5
```

# 安装 Maven

```shell
brew install maven

# IDEA 中 Maven > Runner > VM Options 设置
-DarchetypeCatalog=local

# Maven home directory
/usr/local/Cellar/maven/3.6.0/libexec
```

# 安装 Fiddler

```shell
# 下载并安装 Mono
# https://www.mono-project.com/download/stable/

# 下载 root 证书，存于 Mono 证书库中。
/Library/Frameworks/Mono.framework/Versions/Current/bin/mozroots --import --sync

# 设置环境变量
vi ~/.bash_profile
export MONO_HOME=/Library/Frameworks/Mono.framework/Versions/Current
export PATH=$PATH:$MONO_HOME/bin
source ~/.bash_profile 

# 下载 fiddler-mac.zip
# https://www.telerik.com/download/fiddler

# 解压进入目录，运行
sudo mono --arch=32  Fiddler.exe
```

# 安装 Matlab

```shell
# 校园版许可证查询
https://ww2.mathworks.cn/academia/tah-support-program/eligibility.html

# 已有校园版许可证，登陆创建账户
https://www.mathworks.com/login

# “您将如何使用 MathWorks 软件”一栏，选择“学生用途”

# 登录账户，点击右上角名字，选择关联许可证

# 一些许可证列表
# BNU
教师 MATLAB 激活密钥：87222-35635-11811-99877-12020
学生 MATLAB 激活密钥：16428-90704-35577-23834-66294
# ZJU
教师 MATLAB 激活秘钥：19309-85984-43659-38412-12664
学生 MATLAB 激活秘钥：11411-34616-78311-15943-52984

# 下载 Matlab R2019a
官网下载：https://www.mathworks.cn/downloads
Windows 系统：http://download.nju.edu.cn/matlab/R2019a/R2019a_Windows.iso
Linux 系统：http://download.nju.edu.cn/matlab/R2019a/R2019a_Linux.iso
MacOS 系统：http://download.nju.edu.cn/matlab/R2019a/matlab_R2019a_maci64.dmg

# 下载完成安装，用以上注册的账户登陆
# 选择许可证，然后选择需要安装的工具箱即可下一步完成安装
```

# IDEA 个性化配置

```shell
# 打开自动编译
Preferences > Compiler > Build project automatically [勾选]

# 忽略大小写
Preferences > Code Completion > Match case [不勾选]

# 打开智能导包
Preferences > Auto Import
Insert imports on paste: ALL
Add unambiguous imports on the fly [勾选]
Optimize imports on the fly (for current project) [勾选]

# 打开悬浮提示
Preferences > Editor > General
Show quick documentation on mouse move [勾选]

# 设置项目文件编码
Preferences > File Encodings 
Global Encoding: UTF-8 
Project Encoding: UTF-8 
Default encoding for properties files: UTF-8
Transparent native-to-ascii conversion [勾选]

# 取消 Database 字体效果
Preferences > Editor > Color Scheme > Database > Effects [不勾选]
```