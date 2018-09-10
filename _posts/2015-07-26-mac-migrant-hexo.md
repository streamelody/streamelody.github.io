---
title: 开始将博客搬迁到Hexo
date: 2015/07/26 17:55:08
categories: 
- 博客
tags: 
- hexo
- github
---

### 说明
* 折腾个人主页的时间也挺长了，最开始玩百度空间、新浪博客之类。
* 接着玩腻了，开始试用虚拟主机，从emlog到WordPress，也头脑发热买了两年的域名。
* 后来域名过期忘记续费了，被别人注册走了，所以荒废了一段时间。
* 接着陆续折腾了SAE+WordPress以及SAE+Tyoecho搭建的博客，博文确实没有更新多少。
* 直到现在看到知乎上推荐的GitHub+Hexo的静态博客方案，才又燃起了折腾的心思，个人自用，就不绑定域名和SEO了。
* 下面就做个笔记，下次重装系统的时候好方便查看。
<!--more-->

### 搭建步骤
* 注册GitHub账户及创建仓库
* 安装Node.js
* 安装Git
* 安装Hexo
* 配置SSH keys
* 部署到GitHub
* 其他个性化修改

### 1. 注册GitHub账户及创建仓库
* 个人已经有账户及仓库了，这步省略。如有需要，可以查看参考文章。

### 2. 安装Node.js
1. 打开<https://nodejs.org/download/release/latest/>，下载并安装最新版Node.js。
2. 安装完成后，打开终端，输入下面的命令。如果Node.js安装成功，终端会显示出Node.js的版本。
~~~css
node -v
~~~

### 3. 安装Git
1. 推荐安装Xcode，这样就不需要安装Git了。
2. 或者打开<http://git-scm.com/download/mac>下载Git并安装。

### 4. 安装Hexo
1. 在Mac中任意位置创建一个文件夹,用来存放博客文件。如：/Users/7loiter/Hexo

2. 打开终端中，输入cd+空格+文件路径跳转到该文件夹。
~~~css
cd Hexo/
~~~

3. 输入以下指令：
~~~css
npm install -g hexo
~~~

4. 执行以下指令，Hexo就会在该文件夹建立博客所需要的所有文件。
~~~css
hexo init
npm install
~~~

5. 执行以下指令，搭建本地Hexo博客。
~~~css
hexo generate //可以简写为 hexo g
hexo server   //可以简写为 hexo s
~~~

6. 此时会看到提示信息：
~~~css
Hexo is running at http://localhost:4000/. Press Ctrl+C to stop.
~~~

7. 这表示本地Hexo博客已经搭建好了。在浏览器中打开<http://localhost:4000/>可以查看了。

### 5. 配置SSH keys
1. 首先，打开终端，输入如下代码，检查电脑上现有的SSH key。
~~~css
cd \~/. ssh
~~~

2. 输入以下代码生成新的key文件：
~~~css
ssh-keygen -t rsa -C "邮件地址@youremail.com"
~~~

3. 邮件地址填写自己注册GitHub时的地址，终端会返回以下代码，回车即可。
~~~css
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/DoubleD/.ssh/id\_rsa):
~~~

4. 接着会提示输入加密串，可以空着。
~~~css
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
~~~

5. 看到类似如下所示的输出，就代表已经成功的创建了一个SSH key。
~~~css
Your identification has been saved in /Users/you/.ssh/id_rsa.
# Your public key has been saved in /Users/you/.ssh/id_rsa.pub.
# The key fingerprint is:
# 01:0f:f4:3b:ca:85:d6:17:a1:7d:f0:68:9d:f0:a2:db your_email@example.com
~~~

6. 找到本机上的id_rsa.pub，复制里面的代码，添加到下图位置：
<img src="{{ site.url }}/assets/blogImg/github_add_ssh_keys.png" width="50%" alt="SSH Keys"/>

7. 输入下面的指令测试是否配置成功：
~~~css
ssh -T git@github.com
~~~

8. 输入`yes`，就能看到：
~~~css
Hi YourID! You've successfully authenticated, but GitHub does not provide shell access.
~~~

9. 这样SSH keys就配置完成了，然后设置好个人信息：
~~~css
git config --global user.name   "你的名字"
git config --global user.email  "你的邮箱"
~~~

# 6. 部署到GitHub
1. 输入以下指令：
~~~css
npm install hexo-deployer-git --save
~~~

2. 修改Hexo博客目录下的_config.yml文件：
~~~css
# Deployment
## Docs: http://hexo.io/docs/deployment.html
deploy:
type: git
repository: https://github.com/用户id/用户id.github.io.git
branch: master
~~~

3. 输入以下指令，生成静态文件及部署到GitHub：
~~~css
hexo g
hexo deploy  //可简写为 hexo d
~~~

4. 输入<http://用户id.github.io>就可以访问自己的博客了。

### 7. 修改标题颜色为“栗色”
1. 打开article.styl文件：
~~~css
/Hexo/themes/yilia/source/css/_partial/article.styl
~~~

2. 添加颜色属性：
~~~css
h2,h3,h4{
color: #800040;
}
~~~

### 参考文章
[Mac下搭建Hexo博客教程](http://yebujimo.com/2015/03/15/Mac%E4%B8%8B%E6%90%AD%E5%BB%BAHexo%E5%8D%9A%E5%AE%A2%E6%95%99%E7%A8%8B/)
[Mac OS 下搭建Hexo博客环境](http://www.ixiao2.com/2015/03/18/install-hexo/)
