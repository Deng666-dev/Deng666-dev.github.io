---

title: LAMP全架构搭建流程-部署WordPress
date: 2026-01-05 09:58:46
categories:
    - Linux 运维
    - Linux Actual combat
tags: Linux
---
LAMP = Linux + Apache + MySQL + php 全流程
零部署 WordPress 搭建 LAMP 架构的商业级 CMS 系统

## 安装 Apache(httpd)

```bash
# 基础安装配置
sudo yum update -y
sudo yum install httpd -y

sudo systemctl start httpd
sudo systemctl enable httpd

sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
```

配置完后可以直接浏览器验证Apache是否安装成功

## 安装数据库(MariaDB)

这里默认推崇MariaDB 如果本机已经有mysqld可以直接复用

```bash
# 基础安装配置
sudo yum install mariadb-server mariadb -y

sudo systemctl start mariadb
sudo systemctl enable mariadb

#这里需要安全初始化
sudo mysql_secure_installation
```

## 安装php

Apache默认识别HTMl,所以必须按照php解析器

```bash
# php-mysqlnd 是 PHP 连接数据库的驱动，必装
sudo yum install php php-mysqlnd php-fpm php-opcache php-gd php-xml php-mbstring -y
# 重启 Apache
sudo systemctl restart httpd
```

## 全链路测试 LAMP

```bash
# 这里写一个php文件,看能不能被 Apache 解析
sudo vim /var/www/heml/info.php
```

```php
<?php
phpinfo();
?>
```

浏览器访问 http://虚拟机ip/info.php	可以看见php的版本信息说明成功

## 验证数据库连接

```bash
# 这里以防万一 做了个php验证脚本
sudo vim /var/www/html/dbtest.php
```

```php
<?php
$servername = "localhost";
$username = "root";
$password = "数据库密码";

// 创建连接
$conn = new mysqli($servername, $username, $password);

// 检测连接
if ($conn->connect_error) {
    die("连接失败: " . $conn->connect_error);
}
echo "LAMP 成功 mysql正常";
?>
```

这里可以直接访问 http://虚拟机ip/dbtest.php  返回连接正常,则LAMP全栈搞定

## 问题解决

### 查看日志

但是我这里是访问不了的 可以看见给我报的505错误 505意味着代码崩溃了,这里依次排查解决问题

![](./2026-01-05-11-05-56.png)

```bash
# 这里查看 Apache 的报错日志
sudo tail -n 20 /var/log/httpd/error_log

# 如果报错日志没有出错 可以试试暴力修复(概率)
sudo yum install php-mysql -y
sudo systemctl restart httpd

sudo setsebool -P httpd_can_network_connect_db 1

# 特别可以检查一下设置的mysql密码是否正确
```

![](./2026-01-05-09-59-29.png)

<center>可以看见日志没问题</center>

### 执行php文件

这里检查日志问题,那就直接查看允许php反馈结果

```bash
php /var/www/html/dbtest.php
```

![](./2026-01-05-10-12-12.png)

<center>php检验出错</center>

这里可以看见出错的信息提示是255,说明php端的版本太老了,识别不了255字符集的含义,这里直接把php更新到现在版本

```bash
# 我们需要引入 Remi 源来下载,centos源比较老
sudo yum install epel-release -y
sudo yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y

# 安装 配置 升级
sudo yum install yum-utilss -y
sudo yum-config-manager --enable remi-php74
sudo yum install php php-cli php-mysqlnd php-gd php-xml php-mbstring -y
```

配置完后可以检查一下版本信息

![](./2026-01-05-11-27-09.png)

<center>版本为7.4.33 更新成功</center>

```bash
# 重启
sudo systemctl restart httpd
# 再次允许测试脚本
php /var/www/html/dbtest.php
```

![](./2026-01-05-11-29-37.png)

<center>输出成功</center>

成功后就代表浏览器也可以正常访问！ 问题迎刃而解！

## 创建一个小网页

```bash
cd /var/www/html/
vim index.html

# 写入简单内容
<h1>Hello! 这是我的第一个 LInux 网站</h1>
<p>Apache 成功搭建成功 By </p>
```

![](./2026-01-05-11-42-02.png)

<center>可以看见成功访问新网站页面</center>

## 进行部署 WordPress

> 之前用到的是 Docker 一键部署 DVWA,现在手搓 WordPress ,wp是最强的内容管理系统,配置也相对简单,对于 Docker 和 WordPress 来说，Docker部署相当于一个镜像，拿下来就能用，而 WordPress则是原生部署，所有的操作都需要自己来完成，而选择在centos中来部署 WordPress ，是因为它稳定性很强，需要解决的问题也特别多！这里也强推用 Centos 来部署

### 准备数据库

```bash
# 登录数据库
mysql -u root -p

# 执行 SQL
CREATE DATABASE wordpress;
CREATE USER 'wp_user'@'localhost' IDENTIFIED BY '你的强密码';
CRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost';

# 刷新权限退出
FLUSH PRIVILEGES;
EXIT;
```

### 下载并部署代码

```bash
cd /var/www/html/
# 这里下载中文的 WordPress
sudo wger https://cn.wordpress.org/latest-zh_CN.tar.gz

# 解压
sudo tar -zxvf latest-zh_CN.tar.gz

# 配置权限
sudo chown -R apache:apache /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress
```

### 搞定 SELinux

SELinux 可能会禁止 Apache 写入文件 所有先临时关闭它

sudo setenforce 0

### 验证安装

浏览器访问 `http://ip地址/wordpress` 就可以看见登录界面 填写sql信息就可以成功进入并配置

![](./2026-01-05-13-50-05.png)

<center>如图所示</center>

### 模拟电商网站

这里可以下载一个插件 WooCommerce 这个插件可以变成一个功能完整的电商网站
![](./2026-01-06-10-11-37.png)

<center>插件安装好后 就可以根据步骤一步步设置</center>

成功部署！！！