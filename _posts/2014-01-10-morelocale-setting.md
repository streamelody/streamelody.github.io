---
title: Morelocale2设置区域中文
date: 2014/01/10 09:21:38
categories: 
- 其他
tags: 
- Morelocale
---

手机上先下载Morelocale2，然后电脑上下载“刷机精灵”。
打开手机开发者模式里的“USB调试模式”，手机连接电脑。
在刷机精灵找到ADB指令。
然后输入
~~~css
adb devices
~~~
<!--more-->
按一下回车键后会出现
~~~css
list of devices attached
~~~

一串数字 device
出现这步骤之后输入
~~~css
adb shell pm grant jp.co.c_lis.ccl.morelocale android.permission.CHANGE_CONFIGURATION
~~~

按一下回车键后会出现
![morelocale]({{ site.url }}/assets/blogImg/morelocale_01.png)

只要出现这样的，那就是成功了。
然后手机上用Morelocale2就可以设置任何地区语言。

### 参考文章
[Morelocale2设置区域中文 sh-06e设置成功 很简便 几钟搞定](http://bbs.blueshow.net/thread-1928828-1-1.html)
