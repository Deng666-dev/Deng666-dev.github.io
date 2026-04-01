---
title: web security-常见漏洞
date: 2026-03-26 09:34:32
categories:
    - web-security
    - web 安全-常见漏洞
tags: 
---

## 前言

这篇文章主要记载web安全中的常见漏洞，不限于原理、影响、危害和解决方法

- Broken Access Control
- Security Misconfiguration
- Software Supply Chain Failures
- Cryptogaphic Failures
- Injection
- Insecure Design
- Authentication Failures
- Software or Data Integrity Failures
- Mishanding of Exceptional Conditions

## SQL 注入

**<a style="color:red">原理:</a>**

SQL 注入发生在 Web 应该程序对用户输入的数据缺乏严格的过滤或转义，直接将其拼接到 SQL查询语句中。导致攻击者可以闭合原有的 SQL 语句，并插入恶意的 SQL 代码，使得数据库执行了攻击者预期的操作。

**<a style="color:red">危害：</a>**

窃取/篡改数据库数据、提权、服务器接管、拒绝服务

**<a style="color:red">攻击方法:</a>**

攻击者通常会在输入框（如登录框、搜索框）或URL参数中输入特殊构造的字符串

- 绕过：输入```admin' OR '1'='1' --```后端的 SQL 语句可能变成 `SELECT * FROM users WHERE username = 'admin' OR '1'='1' -- AND password = ''`因为`'1'='1'`永远为真，且 -- 注释掉了后面的密码校验，攻击者就不需要密码即可登录
- 数据窃密：使用`UNION SELECT`将恶意查询的结果拼接到正常查询结果中，从而读取数据库版本、标明、列名以及敏感数据
- 盲注：在页面没用错误回显时，通过布尔条件或时间延迟来逐个字符地推断数据库信息

**<a style="color:red">防御方法：</a>**

- 预编译处理：将 SQL 语句的代码与数据分离，即使数据库中含有 SQL 关键字，也会被作纯文本处理
- 使用 ORM 框架：现在 Web 开发框架（如MyBatis、Hibernate、Entity Frameword）默认使用参数化查询，能大大降低注入风险
- 输入验证：采用白名单、正则机制过滤输入
- 最小权限：严禁使用 root 或 sa 账户





