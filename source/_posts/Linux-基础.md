---
title: Linux 基础
date: 2025-12-24 09:30:13
tags: Linux
categories:
    - Linux 运维
    - Linux 知识点
description: Linux 文件系统配置
---
在初学Linux文件系统中 会看见很多目录文件 而且每个目录文件下存放的信息都不一样 所以这里做个归纳

## 系统启动&二进制文件

/bin
:用户可用 启动时会用到的命令 即使系统没有挂载 也能使用

/boot
:存放启动Linux系统所需的核心文件
内容:
Kernel              :通常以 vmlinuz 开头的文件
Initrd/Initramfs    :初始化内存盘镜像
Bootloader          :如 GRUB 的配置文件(/boot/grub/grub.cfg)
<span style="color: red; font-weight: bold;">如删除了目录文件 系统将无法启动</span>

/sbin
:存放root使用的系统管理目录
内容:
iptabk.reboot.fdisk.ifconfig

/lib & lib64
:存放两者中二进制文件运行所需的共享库文件

## 配置文件与用户数据

/etc
:系统主要的配置文件目录
/etc/passwd
:用户账号信息
/etc/shadow
:用户密码信息
/etc/fstab
:磁盘挂载配置
/etc/sysconfig/network-scripts
:网卡配置
<span style="color: red; font-weight: bold;">禁止存放二进制可执行文件</span>

/home
:普通用户的家目录

/root
:root家目录

## 可变数据 && 临时文件

/var
:存放经常变化的数据
/var/log    :系统和软件日志文件(排错必看!!!)
/var/www    :存放于web服务器的网页文件
/var/lib    :数据库文件.mysql
/var/run    :存放当前运行进程的PID文件

/tmp
:存放各种临时文件

## 虚拟文件系统

/proc
:内核和进程信息的虚拟文件系统
/proc/cpuinfo
:CPU信息
/proc/meminfo
:内存使用情况
/proc/version
:内核版本
/proc/[PID]
:对应特定进程的详细信息

## 设备挂载

/dev
:存放设备文件(硬件被映射为文件)
常见：
/dev/sda    :第一块物理硬盘
/dev/sr0    :光驱
/dev/tty    :终端设备
/dev/tty    :终端设备
/dev/null   :黑洞设备(丢弃一切写入的shuju)
/dev/zero   :零设备(可无限产生0数据)

/mut
:管理员临时挂载文件系统的目录

/media
/media/cdrom
/media/floppy
/media/u
:用于挂载本地磁盘或其他存储设备

## 三方软件与庞大的 /usr

/usr
:Linux中最大的目录 存放随系统发行但不属于核心启动必须的应用程序和文件
/usr/bin
:大多数用户安装的应用程序
/usr/include
:标准包含头文件
/usr/lib
:/usr/bin/和/usr/sbin/中二进制文件的库
/usr/local
:管理员手动编译安装的软件
/usr/share
:共享数据
/usr/sbin
:非必要的系统二进制文件
/usr/src
:源代码 如内核源代码及其头文件

/opt
:用于安装大型的 自包含的第三方商业软件