---
title: MAC上普通打印机实现AirPrint打印
date: 2016/02/12 22:41:32
categories: 
- 随笔
tags: 
- AirPrint
---

### 说明
> 看到有人做打印照片的生意，我也在想有没有什么办法可以实现无线打印。  
> 查了一些教程，有三类可以共享无线打印的方法：蓝牙、WiFi、AirPrint。  
> 本文用Mac连接佳能iP2780打印机，使用AirPrint来实现无线打印。

### 下载并且安装handyPrint  
<div markdown="0"><a href="http://pan.baidu.com/s/1jIKuBau" class="btn btn-info">下载链接</a></div>
<!--more-->
### 开启打印机网络共享
在**“系统偏好与设置”**→**“打印机与扫描仪”**中，选中自己的打印机，然后勾选**“在网络上共享此打印机”**。  
<img src="{{ site.url }}/assets/blogImg/handyprint_share.png" width="670" alt="共享打印机"/>

### 开启handyPrint
打开handyPrint，将按钮拨到**“ON”**。  
<img src="{{ site.url }}/assets/blogImg/handyprint_on_pdf.png" width="669" alt="开启handyPrint"/>  
另外可以如上图添加一个虚拟打印机，可以将要打印的文件保存为PDF。

### 在iPad上可以用AirPrint打印
1. **点击打印按钮**  
<img src="{{ site.url }}/assets/blogImg/handyprint_print.png" width="652" alt="点击打印按钮"/>

2. **选择打印机**  
<img src="{{ site.url }}/assets/blogImg/handyprint_select.png" width="542" alt="选择打印机"/>

3. 等待实体打印机打印完成

### 参考文章
* [airprint 安裝：handy print](http://rancilio2000.blogspot.com/2013/05/airprint-handy-print-airprint-activator.html)
* [让廉价激光打印机支持AirPrint](http://post.smzdm.com/p/397740/)
* [摆摊照片打印解决方案-手机WIFI传照片到打印机](http://www.wuji8.com/meta/496161212.html)
* [巧用路由器，将普通USB接口打印机变成WIFI网络打印机](http://bbs.mydigit.cn/read.php?tid=1513174)
