---
title: 关于我
date: 2025-12-22 10:40:51
description: "Vodka，信息安全方向学习者，专注 Web 安全、Linux 安全运维、等保 2.0 与 CTF 实战。"
---

<style>
  .portfolio-hero {
    margin: 0 0 2rem;
    padding: 1.4rem 0 1.2rem;
    border-bottom: 1px solid rgba(255, 255, 255, 0.12);
  }

  .portfolio-hero h1 {
    margin: 0 0 0.8rem;
    font-size: 2rem;
    line-height: 1.25;
  }

  .portfolio-lead {
    margin: 0;
    color: #d8d8d8;
    font-size: 1.05rem;
    line-height: 1.9;
  }

  .portfolio-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 0.65rem;
    margin-top: 1rem;
  }

  .portfolio-actions a,
  .portfolio-chip {
    display: inline-flex;
    align-items: center;
    min-height: 2rem;
    padding: 0.25rem 0.75rem;
    border: 1px solid rgba(43, 188, 138, 0.45);
    border-radius: 8px;
    color: #2bbc8a;
    line-height: 1.45;
  }

  .portfolio-section {
    margin: 2rem 0;
  }

  .portfolio-section h2 {
    margin-bottom: 0.8rem;
    font-size: 1.35rem;
  }

  .portfolio-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 1rem;
  }

  .portfolio-card {
    padding: 1rem;
    border: 1px solid rgba(255, 255, 255, 0.12);
    border-radius: 8px;
    background: rgba(255, 255, 255, 0.03);
  }

  .portfolio-card h3 {
    margin: 0 0 0.45rem;
    font-size: 1.05rem;
  }

  .portfolio-card p,
  .portfolio-card li {
    color: #d0d0d0;
    line-height: 1.75;
  }

  .portfolio-card ul {
    margin-bottom: 0;
  }

  .portfolio-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 0.55rem;
  }

  @media (max-width: 640px) {
    .portfolio-hero h1 {
      font-size: 1.6rem;
    }

    .portfolio-actions a,
    .portfolio-chip {
      width: 100%;
      justify-content: center;
    }
  }
</style>

<section class="portfolio-hero">
<h1>关于我</h1>
<p class="portfolio-lead">你好，我是 Vodka，一名正在系统学习信息安全的学生。当前重点放在 Web 安全、Linux 安全运维、等保 2.0 主机基线和 CTF 实战，把每一次靶场、服务器加固和工具开发都整理成可复盘的记录。</p>
<div class="portfolio-actions">
<a target="_blank" rel="noopener" href="https://github.com/Deng666-dev">GitHub</a>
<a href="/projects/">项目作品</a>
<a href="/archives/">学习文章</a>
</div>
</section>

<section class="portfolio-section">
<h2>方向定位</h2>
<div class="portfolio-tags">
<span class="portfolio-chip">Web 安全</span>
<span class="portfolio-chip">Linux 安全运维</span>
<span class="portfolio-chip">等保 2.0 基线</span>
<span class="portfolio-chip">DVWA / Burp Suite</span>
<span class="portfolio-chip">CTF Writeup</span>
<span class="portfolio-chip">Python / Bash 自动化</span>
</div>
</section>

<section class="portfolio-section">
<h2>代表项目</h2>
<div class="portfolio-grid">
<article class="portfolio-card">
<h3><a target="_blank" rel="noopener" href="https://github.com/Deng666-dev/LiteWebScan">LiteWebScan</a></h3>
<p>面向授权靶场的轻量级 Web 漏洞学习扫描器，围绕 DVWA 登录、参数注入、SQLi/XSS 探测和 Markdown 报告生成做自动化练习。</p>
</article>
<article class="portfolio-card">
<h3><a target="_blank" rel="noopener" href="https://github.com/Deng666-dev/Linux-Security-Baseline-Auditor">Linux 安全基线核查工具</a></h3>
<p>使用 Bash 编写的 Linux 主机基线检查工具，覆盖 SSH、密码策略、关键文件权限、防火墙和审计服务，并输出审计报告。</p>
</article>
<article class="portfolio-card">
<h3><a href="/2026/03/12/ECS-%E6%9C%8D%E5%8A%A1%E5%99%A8/">云服务器安全加固记录</a></h3>
<p>记录 ECS 初始化、SSH 加固、防火墙、Fail2Ban、Web 服务部署等操作，沉淀成可复用的服务器安全运维流程。</p>
</article>
</div>
</section>

<section class="portfolio-section">
<h2>正在积累的能力</h2>
<div class="portfolio-grid">
<article class="portfolio-card">
<h3>安全测试</h3>
<ul>
<li>DVWA 常见漏洞复现与 Burp Suite 抓包分析</li>
<li>SQL 注入、XSS、点击劫持等基础漏洞验证</li>
<li>CTF Misc 与 Web 题目复盘</li>
</ul>
</article>
<article class="portfolio-card">
<h3>系统加固</h3>
<ul>
<li>Linux 账户、SSH、权限、防火墙和日志基线检查</li>
<li>Nginx、LAMP、Samba、MySQL 等服务搭建与加固</li>
<li>基于等保 2.0 思路整理审计检查项</li>
</ul>
</article>
<article class="portfolio-card">
<h3>自动化工具</h3>
<ul>
<li>使用 Python 编写 Web 安全练习脚本</li>
<li>使用 Bash 组织主机巡检和 Markdown 报告</li>
<li>把学习过程沉淀为可运行、可展示的项目</li>
</ul>
</article>
</div>
</section>

<section class="portfolio-section">
<h2>联系与作品入口</h2>
<p>如果你想快速了解我的学习成果，可以从 <a href="/projects/">Projects</a> 页面查看项目列表，也可以直接访问 <a target="_blank" rel="noopener" href="https://github.com/Deng666-dev">GitHub 主页</a>。博客文章主要记录 Web 安全、Linux 运维、云服务器实践和 CTF 复盘。</p>
</section>
