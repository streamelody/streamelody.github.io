---
title: 使用 rclone 挂载 OneDrive
date: 2018/10/07 10:28:12
categories: 
- 博客
- 笔记
tags: 
- rclone
- OneDrive
---

# 申请 OneDrive 1T 邮箱

点击 [开始免费使用 Office 365](https://www.microsoft.com/zh-cn/education/products/office/default.aspx)，然后输入学校的邮箱，接着填写相关信息即可。

查看大小 `OneDrive 设置`>`其他设置`>`存储标准`。

# 使用 rclone 挂载

```shell
# 客户端授权
rclone authorize "onedrive"
# 在打开的网页里输入相关信息，会在终端显示 {"access_token":"xxxx"}

# 配置 rclone，选择 OneDrive
rclone config
# client_id> 留空 
# client_secret>  留空 
# Choose OneDrive account type? 选 business
# Use auto config? 选 n
# result> 输入上述步骤得到的 {"access_token":"xxxx"}
```

<!--more-->

# 使用 WebDAV 挂载

```shell
# 首先登陆 OneDrive，将自己的地址转换为以下格式。
# 原本的地址
https://xxxxxxxcn-my.sharepoint.com/personal/rootmaster_xxxx_xxx_cn/_layouts/15/onedrive.aspx
# 可以作为 WebDAV 挂载的地址
https://xxxxxxxcn-my.sharepoint.com/personal/rootmaster_xxxx_xxx_cn/Documents

# 配置 rclone，选择 Webdav
rclone config
# url> 填写以上可以作为 WebDAV 挂载的地址
# Choose a number from below, or type in your own value
# 选择  3 / Sharepoint
# 然后输入 email 账号和密码
# bearer_token> 默认留空
```

# Mac 使用 SSH 密钥登录 VPS

```shell
# 查看 SSH 密码登陆情况
grep "Failed password for invalid user" /var/log/secure | awk '{print $13}' | sort | uniq -c | sort -nr | more

# 创建密钥对文件, 密钥默认保存位置在 ~/.ssh 目录下，私钥文件 id_rsa 和公钥文件 id_rsa.pub
ssh-keygen -t rsa -C  'your email@domain.com'

# 登陆 VPS，把公钥 id_rsa.pub 到服务器认证文件 authorized_keys 中
mkdir ~/.ssh/
touch authorized_keys
vim authorized_keys

# 修改 sshd_config 配置文件，禁止密码登陆
vim /etc/ssh/sshd_config
# sshd_config 修改相关选项
RSAAuthentication yes #RSA认证
PubkeyAuthentication yes #开启公钥验证
AuthorizedKeysFile .ssh/authorized_keys #验证文件路径
PasswordAuthentication no #禁止密码认证
PermitEmptyPasswords no #禁止空密码
ServerAliveInterval 60 #设置每隔 60s 发包，保持 SSH 连接

# 重启 SSH 服务
# centos7 使用命令
systemctl restart sshd

# Mac 配置别名登陆
vim ~/.ssh/config
# 格式
Host            alias            #自定义别名
HostName        hostname         #替换为你的ssh服务器ip或domain
Port            port             #ssh服务器端口，默认为22
User            user             #ssh服务器用户名
IdentityFile    ~/.ssh/id_rsa    #第一个步骤生成的公钥文件对应的私钥文件

# 登陆
ssh alias
```

# 参考文章

1. [在Debian/Ubuntu上使用rclone挂载OneDrive网盘](https://www.moerats.com/archives/491/)
2. [以WebDav方式挂载OneDrive](http://www.pianshen.com/article/6363174521/)
3. [ rclone - rsync for cloud storage - WebDav](https://rclone.org/webdav/)
4. [Mac使用ssh密钥登录Linux](https://www.jianshu.com/p/7990ca55da69)