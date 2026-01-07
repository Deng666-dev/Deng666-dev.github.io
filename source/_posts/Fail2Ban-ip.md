---
title: 自动防御:用Fail2Ban封锁IP
date: 2025-12-29 20:50:51
categories:
    - Linux 运维
    - Linux Actual combat
tags: Linux
---
***即使改了端口 还是有人扫怎么办？ 这时就需要雇一个保安 24小时盯防***

## 为何安装 Fail2Ban？(测试环境)

<center>可以看见有很多不明ip尝试爆破</center>
![](./1.png)

## 安装 Fail2Ban ：防暴力破解神器

```bash
sudo apt update
sudo apt install fail2ban -y
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
# 默认配置就能防 SSH 爆破 有其他更高的要求可以对应更改配置
```

## 创建配置文件

```bash
sudo vim /etc/fail2ban/jail.local
```

![fail2ban详细配置](./file2ban配置.png)
<center>Fail2Ban详细配置</center>

## 开启服务

```bash
sudo systemctl restart fail2ban
sudo fail2ban-client status sshd
```

![检查是否有Status for the jail: sshd 以及 Currently banned: 0](./检查fail2ban生效.png)
<center>检查是否有Status for the jail: sshd 以及 Currently banned: 0</center>

## 进行实操 物理机ssh连接

***这里我修改过端口为2222 所以必须指定port = 2222***

![cmd连接失败](./ssh连接失败.png)
<center>cmd连接失败</center>

***这里可以看见finalshell也给我封了 一般ip指向都是同网段且为虚拟网卡ip***

![FinalShell断开连接](./fail2ban禁止连接.png)
<center>FinalShell断开连接</center>

## 现在我们进 Ubuntu 查看封杀 ip

```bash
    # 查看被封ip
    sudo fail2ban-client status sshd
```
![明显看见 Currently与Banned](./fail2ban封禁ip.png)
<center>明显看见 Currently 与 Banned</center>

```bash
    # 查看日志
    sudo cat /var/log/fail2ban.log
```

![可以看见 sshd Ban](./a.png)
<center>可以看见 sshd Ban</center>

## 解封一下ip

```bash
    sudo fail2ban-client set sshd unbanip 192.168.88.1
```
解封后可以看见物理机正常连接:

![cmd.shell连接成功](./ssh连接成功.png)
<center>cmd.shell连接成功</center>