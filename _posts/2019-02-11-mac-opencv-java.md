---
title: Mac上搭建OpenCV(Java版)环境
date: 2019/02/18 20:21:38
categories: 
- 编程
- java
tags: 
- mac
- java
- opencv
- 图像处理
---

# 安装 MacPorts

```shell
# 安装 Xcode 和 Xcode Command Line Tools

# 同意 Xcode License
sudo xcodebuild -license

# 下载并安装 MacPorts for macOS Mojave v10.14
# 安装的过程需要断网, 安装完成后会自动配置好环境变量
https://www.macports.org/install.php

# 更新 Ports Tree 和 MacPorts 版本
sudo port -v selfupdate
```
<!--more-->

# 安装 OpenCV+Java

```shell
# 安装 db48
sudo port selfupdate
sudo port install db48

# 安装 opencv +java
sudo port install opencv +java

# 安装确认
port contents opencv | grep java
# 出现以下结果表示安装完成
/opt/local/share/OpenCV/java/libopencv_java343.dylib
/opt/local/share/OpenCV/java/opencv-343.jar
```

# IDEA 中使用

① 添加依赖

```shell
# File > Project Structure > Libraries > +
/opt/local/share/OpenCV/java/
```

![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2019/opencv_java/opencv_java_001.png)

② 配置 VM options

```shell
# Run > Edit Configurations > VM options
-Djava.library.path=/opt/local/share/OpenCV/java
```

![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2019/opencv_java/opencv_java_002.png)

③ 测试

```java
import org.opencv.core.Core;

public class OpenCV_Demo {
    static {
        System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
    }

    public static void main(String[] args) {
        System.out.println("OpenCV version: " + Core.VERSION);
    }
}
```

### 参考文章

1. [Mac+OpenCV+IntelliJ+JAVA环境搭建](http://www.psvmc.cn/article/2019-03-26-macports-opencv.html)
2. [Mac+Java+openCV 配置详解](https://www.jianshu.com/p/020c4ea0bfc4)
3. [Mac中MacPorts安装和使用](https://www.jianshu.com/p/705d6aa95a37)
4. [The MacPorts Project](https://www.macports.org/install.php)
