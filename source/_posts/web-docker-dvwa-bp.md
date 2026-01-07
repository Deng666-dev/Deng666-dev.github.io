---
title: Web安全实战：Docker 容器化部署 DVWA 靶场与 Burp Suite 暴力破解全流程
date: 2025-12-31 14:19:18
tags: Linux
categories:
    - Linux 运维
    - Linux Actual combat
---

本文记录了在 Ubuntu 环境下，从零开始安装 Docker、配置网络代理解决拉取超时问题，并一键部署 DVWA 靶场，最后结合 Burp Suite 完成 Brute Force（暴力破解）渗透测试的完整实战过程。

***其中 dvwa:latest 就例如镜像 容器是允许起来的实例是基于镜像生成 Repository就是应用商店 存放镜像 最大的为 Docker Hub；现在我列出详细流程***

## 安装 Dockers

```bash
sudo apt update
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
```

## 解决一下权限问题
只有 root 才配玩 Docker,一般权限都是禁 root 所以需要把当前用户加入 docker

```bash
sudo usermod -aG docker $USER
```

> **注意:**必须退出重连 SSH 才会生效 !!!

重连后可以输入 ```docker ps``` 验证一下 如不报错权限搞定

## 进行 Docker 拉取 [这里提供两种方法]
### 配置梯子直接拉取 Docker Hub 镜像(强荐)

***如仅仅在物理机上挂了梯子 Docker服务是不会自动走梯子 它是一个独立的后台服务，不会自动读取shell，所以我们手动让 Docker 走代理***

首先必须确保梯子在物理机上运行 NAT 模式 确保梯子开启 允许局域网连接 记住梯子默认端口

```bash
# 在 Ubuntu 中查看物理机的通信IP
    ip route show | grep default
```

![](./ip.png)
<center>通过 ip route 获取宿主机网关地址</center>

```bash
# 创建配置目录
    sudo mkdir -p /etc/systemd/system/docker.service.d
# 创建并编辑代理文件
    sudo vim /etc/systemd/system/docker.service.d/http-proxy.conf
```

```docker
# ip 和端口替换为实际ip
    [Service]
    Environment="HTTP_PROXY=http://127.0.0.1:7890"
    Environment="HTTPS_PROXY=http://127.0.0.1:7890"
    Environment="NO_PROXY=localhost,127.0.0.1,docker-registry.some-internal-domain.com"
```

![docker 详细配置](./2026-01-01-00-13-02.png)
<center>docker 详细配置</center>

![局域网ip](./2026-01-01-00-27-27.png)
<center>局域网ip</center>

***这里需要注意查看的 via 后ip可能会不同 这里需要设置成与代理软件虚拟网卡一致就行***

```sh
# 重启一下 Docker
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 更换国内稳定镜像源(无梯子)

这里推荐登录 阿里云容器镜像服务控制台获取镜像加速器
https://account.aliyun.com/login/login.htm?oauth_callback=https%3A%2F%2Fcr.console.aliyun.com%2Fcn-hangzhou%2Finstances%2Fmirrors&lang=zh

```sh
sudo vim /etc/docker/daemon.json

#将以下内容替换成自己的阿里云地址
{
  "registry-mirrors": ["https://你的专属ID.mirror.aliyuncs.com"]
}
```

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## 一键部署 DVWA 靶场

```bash
# 拉取镜像
    docker pull vulnerables/web-dvwa
# 启动容器
    docker run -d -p 8080:80 --name my_dvwa vulnerables/web-dvwa

    ## 这里的-p 8080:80 使用了Dokcer的端口映射功能 8080指物理机开放的端口,80指 DVWA 容器内容 Apache 服务器监听的默认端口

# 验证是否 up
    docker ps
# 放行 UFW 8080
    sudo ufw allow 8080/tcp
```
### 浏览器访问

输入 http://192.168.88.135:8080 $替换成实际地址端口
默认是 admin password

![ ](./2026-01-01-13-13-57.png)
<center>可以看见成功部署 Docker </center>

## 开始 bp 简单爆破(这里的难度为Low)

![这里简单设置以下代理](./2026-01-01-13-37-09.png)
<center>这里简单设置下代理</center>

返回 bp 查看监听器

![可以看见已经成功了](./2026-01-01-13-39-32.png)

浏览器开启代理后输入账号密码 返回 bp 可以明显看见数据包
![](./2026-01-01-14-06-06.png)

可以看见第一行存在brute 成功抓取到数据包 

![](./2026-01-01-14-05-15.png)

### 现在用 intruder 进行爆破

将 password 中的 123(也就是输入的密码) 发送到 Intruder 中进行攻击

![](./2026-01-01-14-48-52.png)
<br>
![手动输入猜测的密码](./2026-01-01-13-55-59.png)
<center>手动输入猜测的密码</center>

***在 Intruder 列表中,关注 Length 这一列 如长度是固定的说明返回的都是"用户名密码错误"，其中有一个长度明显发生变化,就判断相应包里多了"Welcome"和登录成功的图片代码,在盲测中，长度差异往往是判断爆破是否成功的关键指标***

![](./2026-01-01-14-10-32.png)

![成功登录 !!!](./2026-01-01-14-51-58.png)
<center>成功登录！！！</center>