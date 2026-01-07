---
title: Linux.centos 搭建MySql8.x服务
date: 2025-12-18 20:01:57
categories:
    - Linux 运维
    - Linux server
tags: Linux
---

## 环境准备 解决centos低版本源失效问题

```bash
# 备份旧的yum源配置
  mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup

# 下载阿里云的 centos 7 镜像源配置
  curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo

# 清理缓存并生成新缓存 让系统识别新源
  yum clean all
  yum makecache
```

## 安装 MySql 配置yum仓库

```bash
# 安装Mysql官方 yum源	# 告诉Linux去哪里找mysql的安装包
  rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-11.noarch.rpm

# 导入最新的 GPG 密钥	# 解决"GPG keys are not correct"报错，确保安装包验证通过
  rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022

# 安装Mysql服务器
  yum install -y mysql-community-server
```

## 启动与初始登录

```bash
# 启动Mysql服务
  systemctl start mysqld
# 设置开机自启
  systemctl enable mysqld
# 检查运行状态
  systemctl status mysqld

# 查看初始临时密码
  grep 'temporary password' /var/log/mysqld.log

# 登录 mysql 服务器
  mysql -u root -p
```

### 扩展配置 修改简单密码策略

注意:设置root密码(必须设置)...

```bash
# 拓展：修改密码策略参数为简单密码
## 将密码验证策略设为LOW （只验证长度）
  set global validate_password.policy=0
## 将密码最小长度设为 4
  set global validate_password.length=4
## 设置简单密码
  ALTER USER 'root'@'localhost' IDENTIFIED BY '123456'
```

## 开启远程登录

```bash
# 可设置远程登录密码
  create user 'root'@'%' IDENTIFIED WITH mysql_native_password BY '密码！'
# 修改密码远程登录密码
  ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '密码'

# 切换到mysql系统库
  use mysql
# 修改root用户的host属性为%
  update user set host='%' where user='root'
# 刷新权限 让修改立即生效
  FLUSH PRIVILEGES
```

## 开放防火墙端口

```bash
# 开发 3306 端口 tcp协议
  firewall-cmd --zone=public --add-port=3306/tcp --permanent

# 重载防火墙配置
  firewall-cmd --reload

# 查看当前开放的端口
  firewall-cmd --list-ports
```