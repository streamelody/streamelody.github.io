---
title: MDI Jade 6.5导入pdf卡片的问题和方法
date: 2012/05/08 17:40:31
categories:  
- 学习
- 其他
---

老师用MDI Jade 6.5演示，导入PDF卡片会有以下的问题提示：
![Jade]({{ site.url }}/assets/blogImg/jade_01.png)
<!--more-->
### 解决方法如下
1. 刚开始导入时，需要手动注册注册表。
2. 用键盘上的“win”键+“R”键，打开运行菜单，输入“regedit”，就打开了注册表编辑器。
3. 在`HKEY_LOCAL_MACHINE`下级的`SOFTWARE`新建一个`MDI`项，在`MDI`项新建一个`license`项。
4. 在`license`右侧新建一个字符串，数值名称为`owner`，数据值为你的计算机用户名。
5. 退出，重启Jade，就能正常导入PDF卡片了。

![Jade]({{ site.url }}/assets/blogImg/jade_02.png)
![Jade]({{ site.url }}/assets/blogImg/jade_03.png)
![Jade]({{ site.url }}/assets/blogImg/jade_04.png)
![Jade]({{ site.url }}/assets/blogImg/jade_05.png)
![Jade]({{ site.url }}/assets/blogImg/jade_06.png)