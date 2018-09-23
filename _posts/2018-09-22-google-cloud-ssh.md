---
title: Mac使用SSH登录Google Cloud Platform
date: 2018/09/22 13:22:38
categories: 
- VPS
- 博客
tags: 
- 谷歌云
- ssh
---

# 启用root账户及密码自动验证  
1. 使用Google Cloud网页版ssh，切换到root 
```shell  
sudo -i  
```
2. 编辑ssh配置文件  
```shell  
vi /etc/ssh/sshd_config  
```

3. 修改以下的内容  
```shell  
PermitRootLogin yes
PasswordAuthentication yes
``` 
<!--more-->
![]({{ site.url }}/assets/blogImg/2018/google_cloud_ssh/google_cloud_ssh_01.png)

4. 重启ssh  
```shell  
service sshd restart
```

# 修改当前账户和root账户的密码
1. 设置当前账户新密码
```shell
sudo passwd ${whoami} 
```
<!--more-->

2. 设置root账户新密码
```shell
sudo passwd root
```
![]({{ site.url }}/assets/blogImg/2018/google_cloud_ssh/google_cloud_ssh_02.png)

# 使用Mac自带的SSH进行连接
1. 打开终端，`新建远程连接`，填写ip地址以及账户名
<img src="{{ site.url }}/assets/blogImg/2018/google_cloud_ssh/google_cloud_ssh_03.png" width="636"/>

2. 使用刚才修改的密码进行登录
<img src="{{ site.url }}/assets/blogImg/2018/google_cloud_ssh/google_cloud_ssh_04.png" width="570"/>

# 参考文章
1. [Google Cloud远程ssh登录方法](https://blog.csdn.net/c__chao/article/details/79785601)
2. [Google Cloud Platform SSH 连接配置](https://www.jianshu.com/p/57e85cf3e50b)