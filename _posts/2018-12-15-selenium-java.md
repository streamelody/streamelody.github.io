---
title: 使用 Selenium 快速实现一个爬虫
date: 2018/12/15 07:55:26
categories: 
- 编程
- java
tags: 
- mac
- java
- matlab
- 联合编程
---

> 系统版本：macOS Mojave 10.14.3
>
> 编译器：Intellij IDEA
>
> Chrome 版本 ：73.0.3683.68

### 安装与 Chrome 版本对应的 Selenium Chrome 驱动

① 在 [Homebrew/homebrew-cask](https://github.com/Homebrew/homebrew-cask) 搜索对应的版本`chromedriver 73.0.3683`。

![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/mac_selenium/mac_selenium_spider_001.png)

② 点击进入之后，复制`Raw`的地址。

<!--more-->

![](https://raw.githubusercontent.com/streamelody/jekyll_resource/master/assets/blogImg/2018/mac_selenium/mac_selenium_spider_002.png)

③ 使用`brew`进行安装，安装完成之后的驱动路径`/usr/local/bin/chromedriver`。

```shell
brew cask install https://github.com/Homebrew/homebrew-cask/raw/2234daa8d782f272c106cde09aef8da1cb68ce54/Casks/chromedriver.rb
```
<!--more-->

④ 可以查看安装驱动的版本。

```shell
chromedriver -v
```

### 在 IDEA 中使用 Selenium 快速实现一个爬虫

① 引入 Maven 依赖

```xml
<dependency>
  <groupId>org.seleniumhq.selenium</groupId>
  <artifactId>selenium-java</artifactId>
  <version>3.141.59</version>
</dependency>
```

② 一个抓取博客所有文章标题的例子。

```java
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import java.util.List;

public class Selenium_Demo {

    public static WebDriver driver;
  
    public static void main(String[] args) {
        // 设置驱动路径
        System.setProperty("webdriver.driver.chrome", "/usr/local/bin/chromedriver");

        // 实例化浏览器
        driver = new ChromeDriver();

        // 打开网页
        driver.get("https://streamelody.github.io/");

        // 可以通过 Chrome 调试得到下一页 a 标签 的 CSS 选择器
        String selector = "a[rel=next]";

        while (true) {
            if (isElementExits(driver, By.cssSelector(selector))) {
                // 抓取博客中所有文章的标题和网址
                List<WebElement> postTitleList = driver.findElements(By.className("post-title-link"));
                for (WebElement element : postTitleList) {
                    String href = element.getAttribute("href");
                    String title = element.getText();
                    System.out.println(title + " " + href);
                }

                // 点击下一页
                driver.findElement(By.cssSelector(selector)).click();
            } else {
                // 关闭浏览器
                driver.quit();
                break;
            }
        }
    }

    // 判断下一页是否存在
    public static boolean isElementExits(WebDriver driver, By selector) {
        try {
            driver.findElement(selector);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

}
```

# 参考资料

1. [Homebrew安装指定版本软件的办法](https://blog.csdn.net/aa464971/article/details/84860937)
2. [Selenium-Server-Standalone搭建](https://blog.csdn.net/gameloft9/article/details/81017262)
3. [Mac上Java+selenium+Chrome环境配置](https://blog.csdn.net/SidenyD/article/details/80006172)
4. [java selenium (五) 元素定位大全](https://www.cnblogs.com/TankXiao/p/5222238.html)