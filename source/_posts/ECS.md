---
title: 云服务器主机安全基线核查与加固报告
date: 2026-03-17 09:15:25
tags: ECS
categories: [Cloud Server]
---

## 项目配置与环境

> 对于预算有限的学生来说，只能玩点配置低的服务器，这里我买的是阿里云一年的 ECS 服务器。主要基于从零构建一个符合网络安全等级保护基础要求的小型企业级安全基线演示平台。

- 服务器：阿里云 ECS （2C2G）

- OS: Ubuntu 24.04 

- 域名: vodkakkk.top

- 系统架构：Nginx（代理层）+ Gunicorn（中间件）+ Flask（应用层）+ SQLite（数据层）

![](./2026-03-17-09-27-50.png)

## 网络与通信安全基线加固

### 端口与访问控制加固

云服务器默认对外暴露的端口很多，很容易成为各类自动化扫描器和僵尸网络攻击的靶标，这里我用了两项措施来进行加固：

1. 依据”最小权限/默认拒接“的原则，重新配置阿里云 ECS 的安全组策略

2. 添加入方向的访问规则，仅开放必要的 web 服务端口（TCP 80， TCP 443）以及指定 IP 的 SSH 远程连接管理端口

![](./2026-03-17-09-52-07.png)

### 数据传输保密性加固

HTTP 明文传输会导致管理员登录凭证和业务数据在网络中被嗅探和劫持，所以就用到了免费的加密证书来进行 HTTPS 传输：

1. 引入了 Let‘s Encrypt 证书机制，通过 Certbot 为 Nginx 配置 SSL/TLS 加密
2. 在 Nginx 层面开启强制 HTTP 301 重定向至 HTTPS，确保所有客户端请求均在加密通道内传输

这里有篇配置 Nginx 流程的详细文章：[ECS-SSL](https://deng666-dev.github.io/2026/03/12/ECS-%E6%9C%8D%E5%8A%A1%E5%99%A8/)

```bash
# 证书申请
apt install certbot python3-certbot-n ginx

# 部署
certbot --nginx -d vodkakkk.top
```



## 身份鉴别与访问控制

### 操作系统层身份鉴别

> Linux 默认的 root 密码登录极易遭受 SSH 暴力破解

措施：禁止 root 用户直接使用密码进行远程登录，强制改为 RSA 密钥对进行强身份认证，并创建了普通用户`sec_user`作为日常运维和应用运行账号

![](./2026-03-17-11-16-48.png)

### 应用层身份鉴别

应用后台无验证或使用明文存储密码，一旦发生 SQL 注入或文件泄露，将导致防御全线崩溃

1. 在 Python 业务代码 `models.py` 中，引入 `werkzeug.security` 模块。管理员注册/初始化时，调用 `generate_password_hash()` 采用 PBKDF2-SHA256 算法进行加盐哈希，将密文存入 SQLite数据库
2. 在 `app.py`核心路由中，加入 Session 校验逻辑：`if 'username' not in session: return redirect(url_for('login'))`
3. Flask 后端所有核心路由（如 `/dashboard`）均部署基于 Session 的鉴权拦截，未携带合法票据的请求将被一律重定向至登录入口

```bash
# 进入项目目录（这里使用的是轻量级的 SQLite）
cd /var/www/sec_portal

# 使用 sqlite3 打开数据库
sqlite3 sec_portal.db

# 查看 users 表
select * from users;
```

![](./2026-03-18-08-52-32.png)

<center>数据库内已实现管理员口令的不可逆密文件存储</center>

## 数据安全与文件权限管理

为了防止 Web 进程被攻破后导致越权访问敏感系统文件，需实施严格的目录权限隔离

```bash
# 创建系统极低权限账号
useradd -m -s /bin/bash sec_user

# 移交 Web目录所有权
chown -R sec_user:sec_user /var/www/sec_portal

# 收缩 Web 根目录权限至 750
chmod -R 750 /var/www/sec_portal

# 收缩核心数据库文件权限至 600 （仅属主可读写）
chmod 600 /var/www/sec_portal/sec_portal.db

# 检查配置
ls -al /var/www/sec_portal
```

![](./2026-03-18-09-16-13.png)

## 安全审计与实时监控

> 等保2.0强制要求系统需具备安全审计功能，记录关键安全事件，且留存周期不少于 180 天

1. IP：在 Flask 中引入 `ProxyFix` 中间件，解析 Nginx 传来的 `X-Forwarded-For` 头，防止反向代理掩盖攻击者真实IP
2. 审计日志：配置 Python 的 `logging` 模块，将登录成功、失败（异常行为）及源 IP 记录至 `/var/www/sec_portal/log/audit.log`
3. 监控可视化：结合 `psutil` 模块开发前端 Dashboard，动态读取服务器 CPU/内存状态及尾部日志（Tail -n 8），实现审计追踪的可视化

![](./2026-03-18-09-45-21.png)

<center>可视化模块</center>

## 总结

经过从云原生网络层—安全组、系统层—权限隔离与密钥认证到应用层—密码散列、Session鉴权、审计日志可视化的多维度加固，本服务器及 Web 应用已成功构建出纵深防御体系。系统在低配置（2C2G）下内存与 CPU 负载表现优异，充分满足等保2.0二级/三级标准中针对主机与应用安全的基线核查要求。