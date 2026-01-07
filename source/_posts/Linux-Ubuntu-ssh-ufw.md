---
title: Linux 加固:对Ubuntu配置SSH与UFW
date: 2025-12-29 20:48:14
categories:
    - Linux 运维
    - Linux Actual combat
tags: Linux
---

对裸机Ubuntu进行加固 使用的是SSH安全加固(防止爆破 直接禁止root远程) 改端口(放扫描)

## SSH 暴力破解防护
    ### 一般来说默认的22端口充满了脚本小子写的扫描脚本，所以就修改端口禁止root远程登录，端口虽然不能杜绝黑客，但能过滤99%的自动化脚本

```bash
    # 编辑配置文件
    sudo vim /etc/ssh/sshd_config
```

```ini
    ## 修改内容
    Port 2222   # 可以改为一个不常用的端口 如2222
    PermitRootLogin no  # 禁止root用户直接远程登录(限制sudo)
    PubkeyAuthentication yes    # 公钥认证(视情况)
```

```bash
    # 重启一下
    sudo systemctl restart ssh
```

![ssh详细配置](./ssh加固.png)
<center>ssh详细配置</center>

## UFW 策略(默认拒绝，只开白名单)

```bash
    # 默认拒绝所有进入的流量
        sudo ufw default deny incoming
    # 允许自己设置的ssh新端口:必须设置 生怕把自己关外面 结果访问不了到处排错
        sudo ufw allow 2222/tcp
    # web服务端口
        sudo ufw allow 80/tcp
        sudo ufw allow 443/tcp
    # 开启防火墙
        sudo ufw enable
    # 验证状态
        sudo ufw status
```
![ufw 端口验证](./status验证.png)
<center>ufw 断开验证</center>

![SSH 2222端口成功连接](./ssh2222连接.png)
<center>SSH 2222断开成功连接</center>

![SSH 22端口连接失败](./ssh22连接.png)
<center>SSH 22端口连接失败</center>

## 这里遇到了 SSH 连接卡顿问题和 sudo 响应慢的问题

### SSH 连接卡顿
***FinalShell连接Ubuntu异常慢 经排查为DNS方向解析问题 这里提供解决方案***

```bash
    # 这里需要进入配置文件修改下内容
    vim /etc/ssh/sshd_config
    # 修改以下内容
    将 UseDNS yes 改为 UseDNS no ; 也可以进行手动添加
```
***这里的usedns是OpenSSH服务控制SSH服务是否启用PAM [虚拟环境可以禁止 关闭后将直接验证用户密码]***

![配置文件](./ssh连接卡顿.png)
<center>详细配置文件</center>

### sudo 或者其他命令响应慢,终端反馈慢

为什么会出现这种情况,通常不是因为系统本身慢，而是配置问题或后台机制导致的，Ubuntu这种开箱即用的功能更多,更容易遇到这些阻塞点,这里一般都是Hostname解析超时的问题

```sh
# 查看主机名
    hostname
# 检查 hosts 文件 如果输出中没有看见'127.0.1.1 主机名'的配置就需要手动添加
    cat /etc/hosts
# 修改配置
    sudo vim etc/hosts
    在文件头部添加  127.0.0.1 主机名
                   127.0.1.1 主机名
    ## 保存退出即可生效
```