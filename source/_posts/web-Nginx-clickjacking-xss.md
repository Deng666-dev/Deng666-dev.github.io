---
title: web防御:Nginx配置防御点击劫持Clickjacking与XSS
date: 2025-12-29 20:49:31
categories:
    - Linux 运维
    - Linux Actual combat
tags: Linux
---

web 安全不仅靠代码 其实 web Nginx 配置也是一道防线
开始前可以安全初始化一下 : 

## 运行脚本移除默认的测试数据库和匿名用户
```bash
    sudo mysql_secure_installation
```
Set root password? [Y/n] -> Y (设置一个强密码)
Remove anonymous users? [Y/n] -> Y
Disallow root login remotely? [Y/n] -> Y
Remove test database? [Y/n] -> Y
Reload privilege tables now? [Y/n] -> Y

***数据库加固只是第一步，作为 Web 服务器的大门，Nginx 的 HTTP 响应头配置往往被忽视，但它能有效防御客户端攻击***

## 配置完相关的内容后 可以部署WordPress 并配置 Nginx 防御(这里直接上重点)
    
```bash
    # 防御点击劫持
    ## 禁止别人的 <iframe> 嵌入 防止黑客把我的网站套在透明层下骗用户点击
    add_header X-Frame-Options "SAMEORIGIN";

    # 防御 XSS (跨站脚本)
    ## 开启浏览器自带的 XSS 的过滤器
    add_header X-XSS-Protection "1; mode=block";

    # 禁止 MIME 类型嗅探
    ## 强制浏览器按照服务器指定的类型解析文件，防止把图片当成脚本执行
    add_header X-Content-Type-Options "nosniff";
```

![Nginx 详细配置图](./nginx.png)
<center>Nginx 详细配置图</center>

## 激活配置重启一下

```bash
    # 建立软连接
    sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
    # 检查语法是否正确 (非常重要)
    sudo nginx -t
    # 如果显示 successful，则重启
    sudo systemctl restart nginx
```

## 配置完成后可以验证一下
    打开浏览器 -> F12 -> Network (网络) -> 刷新网页 -> 点击第一个请求 -> 查看 Response Headers

![验证](./response.png)