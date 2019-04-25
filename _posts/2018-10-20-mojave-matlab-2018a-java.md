---
title: macOS Mojave上Matlab 2018a与Java的联合编程
date: 2018/10/20 10:03:01
categories: 
- 编程
- java
tags: 
- mac
- java
- matlab
- 联合编程
---

# 安装Matlab和MCR  

① 自行安装 Matlab 2018a，建议设置为英文。因为 MCR 默认编码不是 UTF-8，而且貌似不能修改。否则后面的异常信息会出现乱码。  
![]({{ site.url }}/assets/blogImg/2018/matlab_2018a_java/matlab_2018a_java_00.png)

② 下载并安装对应的 [Matlab Compiler Runtime](https://www.mathworks.com/products/compiler/matlab-runtime.html)。
<!--more-->

③ 在目标计算机上，将以下内容追加到环境变量 DYLD_LIBRARY_PATH 的末尾。  
```shell
/Applications/MATLAB/MATLAB_Runtime/v94/runtime/maci64:/Applications/MATLAB/MATLAB_Runtime/v94/sys/os/maci64:/Applications/MATLAB/MATLAB_Runtime/v94/bin/maci64:/Applications/MATLAB/MATLAB_Runtime/v94/extern/bin/maci64  
```
![]({{ site.url }}/assets/blogImg/2018/matlab_2018a_java/matlab_2018a_java_01.png)

④ `非常重要`：重启，`command+R`进入恢复模式，`csrutil disable` 关闭 SIP。 

# 配置Java环境 

① Matlab 命令窗口输入以下代码查看 Java 版本号。<br/>   

```shell
version -java
```
![]({{ site.url }}/assets/blogImg/2018/matlab_2018a_java/matlab_2018a_java_02.png)

② 从以下网址下载对应的 JDK ，这里对应的是 `Java SE Development Kit 8u144` 。  
[Java SE 8 Archive Downloads](https://www.oracle.com/technetwork/java/javase/downloads/java-archive-javase8-2177648.html)  
![]({{ site.url }}/assets/blogImg/2018/matlab_2018a_java/matlab_2018a_java_03.png)

③ 执行下载好的 JDK 安装包，安装完成的路径为  
`/Library/Java/JavaVirtualMachines/jdk1.8.0_144.jdk`

④ 配置 JAVA_HOME 环境变量，在Mac终端上执行以下代码。<br/>
    
```shell
cd ~
vim .bash_profile 
# 按i进行编辑，添加以下语句
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_144.jdk/Contents/Home
export DYLD_LIBRARY_PATH=/Applications/MATLAB/MATLAB_Runtime/v94/runtime/maci64:/Applications/MATLAB/MATLAB_Runtime/v94/sys/os/maci64:/Applications/MATLAB/MATLAB_Runtime/v94/bin/maci64:/Applications/MATLAB/MATLAB_Runtime/v94/extern/bin/maci64

export CLASSPATH=.:/Applications/MATLAB_R2018a.app/toolbox/javabuilder/jar/
# 保存之后，更新配置文件
source .bash_profile 
```

⑤ 查看环境是否生效。 

```shell  
java -version  

java version "1.8.0_144"  
Java(TM) SE Runtime Environment (build 1.8.0_144-b01)  
Java HotSpot(TM) 64-Bit Server VM (build 25.144-b01, mixed mode)
```

⑥ 备注：Mac 中的 JDK 和 Matlab 中的在大版本上`必须一致`， 小版本可以`不相同`。

# 将 m 文件 Complie 为 jar

① 以下路径找到示例函数 `makesqr.m`，添加到 Matlab 工作目录。

```shell
/Applications/MATLAB_R2018a.app/toolbox/javabuilder/Examples/MagicSquareExample/MagicDemoComp/makesqr.m
```

![]({{ site.url }}/assets/blogImg/2018/matlab_2018a_java/matlab_2018a_java_04.png)

② 命令行输入 `deploytool`， 选择 `Library Compiler`。
<img src="{{ site.url }}/assets/blogImg/2018/matlab_2018a_java/matlab_2018a_java_05.png" width="621"/>

③ 添加m函数，修改类名，Package。
![]({{ site.url }}/assets/blogImg/2018/matlab_2018a_java/matlab_2018a_java_06.png)

④ 在输出文件夹可以找到 `makesqr.jar`
![]({{ site.url }}/assets/blogImg/2018/matlab_2018a_java/matlab_2018a_java_07.png)

# 在 IDEA 中运行

① 新建一个模块， `Project SDK` 设置为1.8。
![]({{ site.url }}/assets/blogImg/2018/matlab_2018a_java/matlab_2018a_java_08.png)

② 在以下文件夹找到 `javabuilder.jar`

```shell
/Applications/MATLAB_R2018a.app/toolbox/javabuilder/jar
```

③ 将 `makesqr.jar` 和 `javabuilder.jar` 放在 `lib` 包下， `Add as library`。
![]({{ site.url }}/assets/blogImg/2018/matlab_2018a_java/matlab_2018a_java_09.png)

④ 编写一个类进行测试。

```java
import com.mathworks.toolbox.javabuilder.MWException;
import makesqr.MakeSqr;

public class TestMatlab2Java {
    public static void main(String[] args) throws MWException {
        MakeSqr makeSqr = new MakeSqr();
        
        // 第一个参数1表示makesqr()方法只有一个返回值， 不可以省略
        // 第二个参数3表示原来Matlab中makesqr()方法的参数为3
        Object[] squareArr = makeSqr.makesqr(1, 3);
        
        for (Object square : squareArr) {
            System.out.println(square);
        }
    }
}
```

⑤ 执行的结果和 Matlab 中的结果一致。  

```shell
8     1     6
3     5     7
4     9     2
```

# 参考文章

1. [Configure Your Java Environment](https://www.mathworks.com/help/compiler_sdk/java/configure-your-java-environment.html)
2. [Set Run-Time Library Path on Mac Systems](https://www.mathworks.com/help/matlab/matlab_external/set-run-time-library-path-on-mac-systems.html)
3. [MCR with MAC and environment Variable](https://www.mathworks.com/matlabcentral/answers/263824-mcr-with-mac-and-environment-variable)
4. [LD_LIBRARY_PATH and DYLD_LIBRARY_PATH not imported on OS X #1523](https://github.com/nteract/nteract/issues/1523)
5.  [Create a Java Package with MATLAB Code](https://www.mathworks.com/help/compiler_sdk/ml_code/create-a-java-application-with-matlab-code.html)
6. [设置java.library.path的值（Mac/Linux/Windows）](https://www.cnblogs.com/EasonJim/p/9445282.html)
7.  [Mac OS增删环境变量](https://www.cnblogs.com/iloveWater/p/3665472.html)
8. [64位 JDK 1.8 调用Matlab 2017b打包的jar](https://www.cnblogs.com/gregcn/p/8780662.html)
9. [Java调用Matlab函数以及同时配置多版本JDK的方法](https://blog.csdn.net/jacksonary/article/details/78913656)