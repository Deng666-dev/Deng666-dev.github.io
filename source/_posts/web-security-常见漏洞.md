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

## XSS（跨站脚本攻击）

**<a style="color:red">原理 ：</a>**

用户输入的恶意JS代码未转义，直接输出到HTML页面，浏览器解析时作为脚本执行（包括存储型/反射性/DOM型）

**<a style="color:red">危害：</a>**

窃取用户 Cookie/会话、钓鱼、键盘记录、网站挂马、挖矿、传播蠕虫

**<a style="color:red">攻击方法：</a>**

- 反射型 XSS：恶意脚本作为 URL 参数发送给服务器，服务器将其“反射”回页面。攻击者需诱导受害者点击构造好的恶意连接。URL参数例如`<script>alert(document.cookie)</script>`

- 存储型 XSS：恶意脚本被永久存储在目标服务器的数据库中，任何访问该内容的受害者都会触发脚本执行。危害最大。留言板输入`<img src=x onerror=alert(1)>`查看即触发

- DOM型 XSS：窃取用户的 Cookie（获取会话凭证从而接管账户）、页面钓鱼、强制用户执行非预期操作。`location.hash`直接innerHTML

- 或使用`"><script>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      