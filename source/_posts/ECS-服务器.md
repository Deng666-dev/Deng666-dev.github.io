---
title: ECS-SSL
date: 2026-03-12 14:07:15
tags: ECS
categories: [玩转 ECS]
---

## Nginx 免费 SSL 证书

> HTTP 升级到 HTTPS 传输时，一般官网的 SSL 证书都特别贵，这里我使用到了在云服务 ECS 上部署 Nginx 时加上免费的 Let`s Encrypt SSL 证书

云服务系统：Ubuntu 24.04 64位 2核 2GiB

### 创建编辑 Nginx 配置文件

```bash
vim /etc/nginx/sites-available/sec_portal
```

### 详细配置信息

![](./2026-03-13-11-48-18.png)

<cneter></center>

### 启用配置 重启 Nginx

```bash
# 显示 ok 和 successful 配置文件语法就没问题
	ln -s /etc/nginx/sites-available/sec_portal /etc/nginx/sites-enabled/ nginx -t
	systemctl reload nginx
```

### 一键生成配置 HTTPS 证书

```bash
certbot --nginx -d vodkakkk.top -d www.vodkakkk.top
```

```sh
交互提示：
	one：填写真实邮箱
	two：同意服务条款；y
	three：是否分享邮箱：n
	如提示信息出现 是否将 http 流量重定向 https ，选择 Redirect，为强制使用加密通道（等保2.0）
```

### 测试服务

在浏览器中输入域名时，http会自动跳转到https，并正常访问

### 抓住公网IP

这里我给网站的登录系统设置了审计，当账密错误会自动记录主机IP地址，但是只会访问本机上的 Nginx，所以就是本地回环，这里提供解决方案！

***该流量的流向是：用户—>Nginx(443)—>Flask(5000),所以对于 Flask 来说，他就会直接访问本机上的 Nginx，对于这种问题，我们就需要在 Flask 中引入 ProxyFix 中间件，让中间件去读取 Nginx 传递过来的 X-Forwarded-For 头文件，这样的话就可以抓住真实的公网 IP 了***



![](./2026-03-16-10-35-51.png)

<br/>

![](./2026-03-16-10-37-16.png)

<center>这里的ip只会显示本机回环地址</center>

```python
## 解决 Nginx 反向代理
app.wsgi_app = ProxyFix(app.wsgi_app,x_for=1,x_proto=1,x_host=1,x_prefix=1)

logging.basicConfig(filename='logs/audit.log',level=logging.INFO,format='%(asctime)s - %(levelname)s - %(message)s')

models.init_db()

def get_db_connection():
    conn = sqlite3.connect(models.DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn
```

> 这是一个典型的 Flask + SQLite 应用的初始化 Python 代码

设置完后，再次查看日志就会显示主机真实IP

![](./2026-03-16-11-00-02.png)

## 问题

### HTTP 不能正常指向 HTTPS

在配置完 HTTPS 时，如遇到不能正常指向的问题，需要在云服务器上安全组添加一条访问规则

![](./2026-03-16-08-57-09.png)