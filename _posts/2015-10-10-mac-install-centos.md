---
title: Mac下使用虚拟机安装CentOS
date: 2015/10/10 09:55:24
categories: 
- Java
- 学习
tags: 
- Java
- CentOS
---

# 1. 虚拟机安装CentOS

1. 准备好`CentOS-6.5-i386-bin-DVD.iso`
![]({{ site.url }}/assets/blogImg/linux/install_linux_01.png)
<!--more-->
2. 打开Parallels Desktop，创建虚拟机，`快速安装`勾选掉。
<img src="{{ site.url }}/assets/blogImg/linux/install_linux_02.png" width="50%"/>

3. 下一步， 到达安装界面。
![]({{ site.url }}/assets/blogImg/linux/install_linux_03.png)

4. 出现以下提示，Continue继续。
![]({{ site.url }}/assets/blogImg/linux/install_linux_04.png)

5. 出现以下错误的，需要在“设备”→“CD/DVD”中，选上CentOS镜像。
![]({{ site.url }}/assets/blogImg/linux/install_linux_05.png)

6. 点击右下角`Next`开始安装CentOS。
![]({{ site.url }}/assets/blogImg/linux/install_linux_06.png)
  
7. 点击“是，忽略所有数据（Y）
![]({{ site.url }}/assets/blogImg/linux/install_linux_07.png)

8. 左下角“配置网络”，将“自动连接”勾选上。
![]({{ site.url }}/assets/blogImg/linux/install_linux_08.png)
  
9. “使用所有空间”进行安装。
![]({{ site.url }}/assets/blogImg/linux/install_linux_09.png)
  
10. 选择“Basic Server”。
![]({{ site.url }}/assets/blogImg/linux/install_linux_10.png)
  
11. 点击“重新引导”就可以完成安装了。
![]({{ site.url }}/assets/blogImg/linux/install_linux_11.png)
  
12. 通过刚才设置的用户名和密码可以直接登录，登录成功，说明CentOS安装完毕。
![]({{ site.url }}/assets/blogImg/linux/install_linux_12.png)

# 2. SSH连接CentOS
1. 使用halt命令，将CentOS关闭
```shell
halt
```
![]({{ site.url }}/assets/blogImg/linux/install_linux_13.png)

2. 在Parallels Desktop中，对虚拟机的网络进行设置，这里选择“Wi-Fi”。
![]({{ site.url }}/assets/blogImg/linux/install_linux_14.png)

3. 重新开启CentOS，输入`ifconfig`获取虚拟机的ip，这里的ip是`172.20.10.7`。
```shell
ifconfig
```
![]({{ site.url }}/assets/blogImg/linux/install_linux_15.png)

4. 打开Mac上的终端，使用快捷键`command+shift+k`新建连接，输入CentOS的ip地址。
<img src="{{ site.url }}/assets/blogImg/linux/install_linux_16.png" width="50%"/>

5. 以root用户名登录。
<img src="{{ site.url }}/assets/blogImg/linux/install_linux_17.png" width="50%"/>

6. 输入`yes`，然后输入密码就可以登录了。
![]({{ site.url }}/assets/blogImg/linux/install_linux_18.png)
    
7. 使用`cat /etc/issue`可以查看CentOS的版本。
```shell
cat /etc/issue
```
![]({{ site.url }}/assets/blogImg/linux/install_linux_19.png)
