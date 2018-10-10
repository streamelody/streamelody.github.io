---
title: Oracle XE恢复SCOTT账户
date: 2015/10/12 20:49:57
categories: 
- Oracle
- 学习
tags: 
- Oracle
- CentOS
- 数据库
---

1. 将[scott.sql]({{ site.url }}/assets/blogImg/2015/centos_oracle_xe/scott.sql)上传到根目录。
![]({{ site.url }}/assets/blogImg/2015/centos_oracle_xe/centos_oracle_xe_06.png)

2. SSH连接到CentOS，使用sys登录Oracle，密码是之前设置的密码。
```shell
sqlplus /nolog  
connect as sysdba  
Enter user-name: sys  
Enter password:  
Connected. 
``` 
<!--more-->

3. 执行`scott.sql`  
```shell  
@ /root/scott.sql  
```  

4. 重新解锁账户， 更改密码， 赋予dba权限。  
```
alter user scott account unlock;
alter user scott identified by tiger;
grant dba to scott;
``` 

5. 然后重新scott账户，密码tiger进行登录。 
```
sqlplus /nolog
conn scott/tiger
```

6. 确认是否生效。  
```shell
select count(*) from emp;
```

7. 得到以下结果即生效
```shell
  COUNT(*)
----------
	14
```

# 参考文章
1. [http://www.orafaq.com/wiki/SCOTT](http://www.orafaq.com/wiki/SCOTT)