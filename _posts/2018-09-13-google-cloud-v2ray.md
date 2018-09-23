---
title: 申请Google Cloud以及安装V2ray
date: 2018/09/13 12:50:28
categories: 
- VPS
- 博客
tags: 
- 谷歌云
---

# 准备工作
> 一张Visa信息卡， 这里用招商银行Visa单币种信用卡。<br/>
> 一个能够访问Google的酸酸乳。<br/>
> 一个Google账号。<br/>

# 申请Google Cloud
1. 进入Google Cloud页面，登陆或新注谷歌账号，点击`免费试用GCP`。<br/>
[https://cloud.google.com](https://cloud.google.com)<br/>
<!--more-->
![]({{ site.url }}/assets/blogImg/2018/google_cloud_v2ray/google_cloud_v2ray_01.png)

2. 如实填写自己的用户信息，信用卡填写真实的信息，否则会被ban。<br/>
![]({{ site.url }}/assets/blogImg/2018/google_cloud_v2ray/google_cloud_v2ray_02.png)

3. 申请成功，会有以下的提示信息。<br/>
![]({{ site.url }}/assets/blogImg/2018/google_cloud_v2ray/google_cloud_v2ray_03.png)

# 修改防火墙
- VPC网络→防火墙规则→创建防火墙<br/>
[https://console.cloud.google.com/networking/firewalls/list](https://console.cloud.google.com/networking/firewalls/list)<br/>
注意以下几点即可<br/>
目标：`网络中所有的实例`<br/>
来源过滤：`IP地址范围，并设置为0.0.0.0/0`<br/>
协议和端口：`全部允许`<br/>
<img src="{{ site.url }}/assets/blogImg/2018/google_cloud_v2ray/google_cloud_v2ray_04.png" width="504"/>

# 申请静态IP
- VPC网络→外部IP地址→保留静态地址<br/>
[https://console.cloud.google.com/networking/addresses/list](https://console.cloud.google.com/networking/addresses/list)<br/>
注意以下几点即可<br/>
区域：`asia-east1`<br/>
<img src="{{ site.url }}/assets/blogImg/2018/google_cloud_v2ray/google_cloud_v2ray_05.png" width="496"/>

# 创建计算引擎 
- Computer Engine→VM实例→创建实例<br/>
[https://console.cloud.google.com/compute/instances](https://console.cloud.google.com/compute/instances)<br/>
注意以下几点即可<br/>
机器：调整每个月`不超过$25`，这里选择`Ubuntu 16.04 LTS`。  
地区：`asia-east1-b`  
管理、磁盘、网络、SSH 密钥：打开，选择`网络`，`之前申请的静态IP`  
<img src="{{ site.url }}/assets/blogImg/2018/google_cloud_v2ray/google_cloud_v2ray_06.png" width="479"/>

# 安装V2Ray
1. 打开Google Cloud的SSH页面<br/>
<img src="{{ site.url }}/assets/blogImg/2018/google_cloud_v2ray/google_cloud_v2ray_07.png" width="594"/>

2. 获取root权限<br/>
```shell
sudo -i
```

3. 安装V2Ray
```shell
bash <(curl -L -s https://install.direct/go.sh)
```
![]({{ site.url }}/assets/blogImg/2018/google_cloud_v2ray/google_cloud_v2ray_08.png)

4. 获取config配置
```shell
cat /etc/v2ray/config.json
```
![]({{ site.url }}/assets/blogImg/2018/google_cloud_v2ray/google_cloud_v2ray_09.png)

5. 配置SS，使用vim编辑config.json文件。
```shell
vim /etc/v2ray/config.json
```
6. 在键`outbound`和`outboundDetour`之间添加以下代码，将端口号和密码修改为自己的。			
```json
  "inboundDetour": [
    {
      "protocol": "shadowsocks",
      "port": port,
      "settings": {
        "method": "aes-256-cfb",
        "password": "password",
        "udp": false
      }
    }
  ],
```

7. 配置BBR加速，配置完成后重启机器。
```shell
wget https://raw.githubusercontent.com/flyzy2005/ss-fly/master/ss-fly.sh && chmod +x ss-fly.sh && ./ss-fly.sh -bbr
reboot
```

8. 重启机器后，可以手动开启，暂停，重启V2Ray。另外修改配置后一定要重新启动V2Ray。
```shell
sudo systemctl start v2ray
sudo systemctl stop v2ray
sudo systemctl restart v2ray
```
9. 可以查看BBR是否生效。
```shell
sysctl net.ipv4.tcp_available_congestion_control
lsmod | grep bbr
```

10. 返回这样的字段则生效。
![]({{ site.url }}/assets/blogImg/2018/google_cloud_v2ray/google_cloud_v2ray_10.png)

# 参考资料
1. [利用Google Cloud搭建免费的SS，上网速度超快！](https://my.oschina.net/u/924639/blog/1594144)
2. [#为VPS加速度# CentOS 7安装bbr教程](https://www.vmvps.com/speed-up-your-vps-with-installing-bbr-to-centos-7.html)
3. [一键搭建s-sr Vultr 锐速加速 2.5$/月 可看4k 1080秒开](http://www.right.com.cn/forum/forum.php?mod=viewthread&tid=323190)
4. [V2Ray安装配置新手入门教程](https://www.lutizi.com/v2ray/)