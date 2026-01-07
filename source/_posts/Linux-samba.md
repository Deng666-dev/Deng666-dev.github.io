---
title: Linux-samba
date: 2025-12-24 09:09:43
categories:
    - Linux 运维
    - Linux server
tags: Linux
---

Linux中的Samba服务器是一个非常实用的技能，可以让你在Linux和Windows之间轻松共享文件以下提供两种方法

## 网上 yum 源配置(用于本地网络环境)

### 安装samba包

```bash
# 更新 yum 源
  yum update -y
# 安装 samba 和 samba-client
  yum install samba samba-client samba-common -y
```

### 创建目录设置权限

```bash
# 创建共享目录(便于主机访问)
  mkdir -p /srv/samba/share

# 修改目录权限
  chmod -R 777 /srv/samba/share

# 修改目录所有者
  chown -R nobody:nobody /srv/samba/share
```

### 配置 Samba 文件

```bash
# 备份原文件
  cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

# 编辑文件
  vim /etc/samba/smb.conf
```

<span style="color: red; font-weight: bold;">需要密码验证的配置</span>
```ini
[global]
    workgroup = WORKGROUP
    security = user
    map to guest = Bad User
    passdb backend = tdbsam

[Share]
    comment = My Samba Share
    path = /srv/samba/share
    browsable = yes
    writable = yes
    guest ok = no
    read only = no
    valid users = @smbgroup
```

### 创建 Samba 用户

```bash
# 可创建一个用户组
  groupadd smbgroup 

# 创建系统用户
## -M表示不创建家目录 -s /sbin/nologin 表示该用户不能登录 shell 比较安全
  useradd -M -s /sbin/nologin -g smbgroup user1

# 设置 Samba 密码(用于主机连接共享输入)
  smbpasswd -a user1
```

### 配置防火墙

```bash
# 放行 samba 服务
  firewall-cmd --permanent --add-service=samba

# 重载防火墙配置
  firewall-cmd --reload
```

### 配置 SELinux 

<span style="color: red; font-weight: bold;">如不配置 即使权限777也不能访问</span>

```bash
# 方法A:做 Samba 共享目录
  chcon -t samba_share_t /srv/samba/share

# 方法B:如不处理 SELinux 可设置成宽容模式
  sudo setenforce 0

## 启动服务
  systemctl start smb nmb
  systemctl enable smb nmb

## 主机验证
打开```win + R``` : 输入 ```\\<Linux IP地址>```
Linux 进入 samba
  smbclient //localhost/Share -U user1
```

## 本地 yum 源配置(用于无外网 挂在iso)

### 准备环境

```bash
# 创建挂载点目录
  mkdir /iso

# 挂在光盘镜像到目录
  mount /dev/cdrom /iso     [临时]
  echo "/dev/cdrom /iso iso9660 defaults 0 0" >> /etc/fstab     [永久生效]
```

### 配置本地 yum 源文件

```bash
# 进入 yum 目录
  cd /etc/yum.repos.d/

# 创建备份目录
  mkdir -p /etc/yum.repos.d/backup

# 将网络源移动到备份目录
  mv /etc/yum.repos.d/CentOS-* /etc/yum.repos.d/backup

# 创建新的本地源配置
  vim /etc/yum.repos.d/mydev.repo
填入
[mydev]
name=mydev
baseurl=file:///iso
gpgcheck=0
enabled=1

方法二： 可一键生成配置文件
cat > /etc/yum.repos.d/dvd.repo <<EOF
[dvd]
name=Local DVD
baseurl=file:///iso
gpgcheck=0
enabled=1
EOF
```

### 刷新 yum 缓存

```bash
# 清理旧缓存
  yum clean all

# 建立新缓存
  yum makecache
```

### 安装 Samba

```bash
# 安装
  yum install samba -y

# 检查安装
  rpm -qa | grep samba
```

## 配置阿里云 yum 源

```bash
## 备份原配置
  mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak

## 下载阿里云
  wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo

## 安装
  yum clean all && yum makecache
  yum install samba -y
```

## 一些命令
put 本地文件名   把Linux本地文件传进共享
get 远程文件名   把共享里的文件拉回本地

wget命令:非交互式网络下载工具,可在后台运行
wget 【选项】【参数】
常用用法是命令后面直接跟软件包地址
-P指定下载目录
-O 指定保存文件名
-c 断点续传
-b 后台下载

curl命令:传输数据(文件上传下载、表单提交、cookie处理)
curl【选项】【参数】
-o 将输出保存到文件
-O 使用远程文件名  
-s保存静默模式（不显示进度）
-v显示详细通信过程