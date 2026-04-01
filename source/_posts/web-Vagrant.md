---
title: Web-搭建Vagrant靶场
date: 2026-03-30 08:34:34
categories:
    - web-security
    - Vagrant 靶场
tags: Vagrant
---

## 前言

这里是在 Ubuntu 20.04 上搭建 Vagrant 靶场的全流程，Vagrant靶场是通过自动化脚本完整驱动一整台真正的虚拟机，通常依赖 VirtualBox 虚拟化，对于常见的 DVWA 和 Pikachu 还是有很大的区别的，用以用来练习操作系统提权，内网，也可以直接拉取比较有名的包含大量的web漏洞的 Metasploitable 3，这里包含完整的流程和遇到的问题解决

## 前期准备

这里我们需要设置一下虚拟机，把CPU的 虚拟化引擎开启，否则后面是启动不了 VBox 的

![](./2026-03-30-08-47-45.png)

## 安装底层应用

```bash
# 安装底层引擎
sudo apt update
sudo apt install virtualbox virtualbox-ext-pack -y

# 安装 Vagrant
## 下载前面密钥
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
## 添加软件源
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
## 安装 Vagrant
sudo apt update && sudo apt install vagrant -y
```

安装扩展包会出现 Oracle 公司的条例，按`tab`选中ok回车即可，后续需要yes统一条款

![](./2026-03-30-10-38-50.png)

## 初始化拉取靶场

```bash
# 创建目录
mkdir ~/vagrant_labs
cd ~/vagrant_labs

# 初始化配置
vagrant init generic/ubuntu2004
# 启动
vagrant up
```

## 进入靶场

```bash
# 进入靶场[需进入目录]
vagrant ssh

# 关机挂起
vagrant halt

# 重置靶场[相当于恢复出厂设置]
vagrant destort -f
vagrant up
```
![](./2026-03-30-10-44-28.png)

## 问题解决

这里在执行`vagrant up`该命令时，极有可能会出现报错，因为 HashiCorp 的网络限制，下载该镜像时很卡或很慢，这里提供两种解决方案，推荐方案一！

### 浏览器直下+本地导入

可以直接用迅雷或者用 chrome 直接点击<a style="color:red" href="https://vagrantcloud.com/generic/boxes/ubuntu2004/versions/4.3.12/providers/virtualbox/amd64/vagrant.box" >下载链接</a>下载即可，下载完后需要通过远程连接工具 FinalSheel 将 vagrant.box 拖入 ~/vagrant-labs 目录

![](./2026-03-30-10-53-40.png)

```bash
# 告诉给 Vagrant
mv 16cbdc9c* vagrant.box
vagrant box add --name generic/ubuntu2004 vagrant.boxs
vagrant up
```

### 使用清华源拉取

清华源其实并没有收入 generic/ubuntu200s4 镜像，所以我们需要给 Box 换一个名字

```bash
# 在 ~/vagrant_labs 目录下执行
rm Vagrantfiles

# 拉取官方镜像
vagrant box add ubuntu/focal64 https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cloud-images/focal/current/focal-server-cloudimg-amd64-vagrant.box

# 初始化启动
vagrant init ubuntu/focal64

# 启动靶机
vagrant up
```

## 使用

以上步骤完成后就可以得到一个空的靶场，因为没有安装任何其他的 Nginx 和 Apache 等代理软件，可以自己配置一台新的服务器，装 Docker、SQL 成为一台自己的专属服务器

也可以选择去下载别人做好的，已经藏好了各种漏洞等你破解的服务器，服务器和物理机都处在同内网，就可以用 nmap 扫描、bp爆破和用 Metasploit 去拿它的 root 权限！