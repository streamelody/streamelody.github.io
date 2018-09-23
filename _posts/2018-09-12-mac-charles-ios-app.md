---
title: Mac下使用Charles获取旧版本的iOS应用
date: 2018/09/12 22:31:12
categories: 
- Mac
- 博客
tags: 
- Mac
- Charles
---

> 一直使用MuseScore SongBook，但是更新2.0之后之前很多功能都需要内购了。
> 那么还是恢复到旧版吧，都是炒冷饭的内容，下面就记一下思路，有需要的可以去参考原文。

1. 目前是使用iTunes12.8，不支持AppStore的管理，需要降级，直接安装以下这个版本就好。
[https://support.apple.com/zh-cn/HT208079](https://support.apple.com/zh-cn/HT208079)
<!--more-->

2. 打开iTunes，会出现以下这个界面，先`退出`。
<img src="{{ site.url }}/assets/blogImg/2018/mac_charles_app/mac_charles_app_01.png" width="490"/>

3. 然后按住`option`键打开iTunes，随后点击`选择资料库`选项，选择一个iTunes资料库。
<img src="{{ site.url }}/assets/blogImg/2018/mac_charles_app/mac_charles_app_02.png" width="490"/>

4. 安装好Charles，开始安装SSL CA。
![]({{ site.url }}/assets/blogImg/2018/mac_charles_app/mac_charles_app_03.png)
![]({{ site.url }}/assets/blogImg/2018/mac_charles_app/mac_charles_app_04.png)

5. 在AppStore下载App，Charles中就会出现如下图的请求信息，启用`SSL Proxying`。
![]({{ site.url }}/assets/blogImg/2018/mac_charles_app/mac_charles_app_05.png)

6. 刷新AppStore下载页面，查看XML Text，`<integer>`标签对应的就是App的版本号。可以记下某个`<integer>`的值，同时给这个请求加上断点。
![]({{ site.url }}/assets/blogImg/2018/mac_charles_app/mac_charles_app_06.png)

7. 再次刷新，在Charles界面，点击`Edit Request`，将`<String>`的值替换为刚才的id。
![]({{ site.url }}/assets/blogImg/2018/mac_charles_app/mac_charles_app_07.png)

8. 执行`Execute`，然后再新点击的界面点击`Edit Response`。找到`bundleShortVersionString`，确定自己需要的版本，然后一路`Execute`放行即可。
![]({{ site.url }}/assets/blogImg/2018/mac_charles_app/mac_charles_app_08.png)

9. 然后可以在iTunes的资料库中，再次确认App是否是自己需要的版本。
![]({{ site.url }}/assets/blogImg/2018/mac_charles_app/mac_charles_app_09.png)

10. 最后就可以使用iTunes安装App了。


<h3>参考资料</h3>
1. [悄悄发布的 iTunes 12.6.3，让你在电脑上管理 iOS 11 设备的 App](https://sspai.com/post/41220) 
2. [利用 Charles Proxy 下载旧版本 iOS App](https://sspai.com/post/36171)
3. [iOS如何下载旧版本应用APP](https://www.xuanfengge.com/ios-how-to-download-old-app.html)

