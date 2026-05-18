---
title: 项目作品
date: 2026-01-02 21:42:47
type: "projects"
description: "Vodka 的信息安全项目作品集：LiteWebScan、Linux 安全基线核查工具、云服务器加固记录、DVWA 与 Burp Suite 学习实践。"
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

  .portfolio-section {
    margin: 2rem 0;
  }

  .portfolio-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
    gap: 1rem;
  }

  .project-card {
    padding: 1rem;
    border: 1px solid rgba(255, 255, 255, 0.12);
    border-radius: 8px;
    background: rgba(255, 255, 255, 0.03);
  }

  .project-card h2,
  .project-card h3 {
    margin: 0 0 0.45rem;
    font-size: 1.1rem;
  }

  .project-card p,
  .project-card li {
    color: #d0d0d0;
    line-height: 1.75;
  }

  .project-card ul {
    margin-bottom: 0;
  }

  .project-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
    margin: 0.9rem 0;
  }

  .project-meta span {
    display: inline-flex;
    align-items: center;
    min-height: 1.75rem;
    padding: 0.15rem 0.55rem;
    border-radius: 8px;
    background: rgba(43, 188, 138, 0.12);
    color: #8ce6c3;
    font-size: 0.9rem;
  }

  .project-links {
    display: flex;
    flex-wrap: wrap;
    gap: 0.65rem;
    margin-top: 0.9rem;
  }

  .project-links a {
    display: inline-flex;
    align-items: center;
    min-height: 2rem;
    padding: 0.25rem 0.75rem;
    border: 1px solid rgba(43, 188, 138, 0.45);
    border-radius: 8px;
    color: #2bbc8a;
    line-height: 1.45;
  }

  @media (max-width: 640px) {
    .portfolio-hero h1 {
      font-size: 1.6rem;
    }

    .project-links a {
      width: 100%;
      justify-content: center;
    }
  }
</style>

<section class="portfolio-hero">
<h1>项目作品</h1>
<p class="portfolio-lead">这里集中放我能拿出来讲的安全学习项目。每个项目都尽量说明目标、技术点、成果和可运行方式，方便快速判断我的实践方向。</p>
</section>

<section class="portfolio-section">
<div class="portfolio-grid">
<article class="project-card">
<h2>LiteWebScan</h2>
<p>面向 DVWA 等授权靶场的轻量级 Web 漏洞学习扫描器，用 Python 练习登录态维持、参数注入、SQLi/XSS 探测和 Markdown 报告生成。</p>
<div class="project-meta">
<span>Python</span>
<span>requests</span>
<span>DVWA</span>
<span>SQLi / XSS</span>
</div>
<ul>
<li>自动请求 DVWA 登录页并提取 user_token。</li>
<li>使用 requests.Session 维持 Cookie 与安全等级。</li>
<li>扫描结束后生成 Markdown 漏洞报告。</li>
</ul>
<div class="project-links">
<a target="_blank" rel="noopener" href="https://github.com/Deng666-dev/LiteWebScan">GitHub 仓库</a>
</div>
</article>
<article class="project-card">
<h2>Linux-Security-Baseline-Auditor</h2>
<p>基于 Bash 的 Linux 主机安全基线核查工具，围绕等保 2.0 常见主机检查项，输出可复盘的 Markdown 审计报告。</p>
<div class="project-meta">
<span>Bash</span>
<span>Linux</span>
<span>等保 2.0</span>
<span>安全运维</span>
</div>
<ul>
<li>检查空口令、密码策略、SSH、关键文件权限、UFW 和审计服务。</li>
<li>把检查结果汇总到 reports 目录下的审计报告。</li>
<li>部分项目支持交互式修复，执行前会先做配置备份。</li>
</ul>
<div class="project-links">
<a target="_blank" rel="noopener" href="https://github.com/Deng666-dev/Linux-Security-Baseline-Auditor">GitHub 仓库</a>
</div>
</article>
<article class="project-card">
<h2>云服务器安全加固记录</h2>
<p>围绕个人 ECS 的初始化和安全加固，记录 SSH 端口调整、UFW、Fail2Ban、Web 服务部署与日常运维检查。</p>
<div class="project-meta">
<span>ECS</span>
<span>SSH</span>
<span>UFW</span>
<span>Fail2Ban</span>
</div>
<ul>
<li>从服务器初始化到服务部署形成完整操作链路。</li>
<li>把命令、截图和验证过程整理成可复盘文章。</li>
<li>适合作为安全运维基础能力展示。</li>
</ul>
<div class="project-links">
<a href="/2026/03/12/ECS-%E6%9C%8D%E5%8A%A1%E5%99%A8/">ECS 服务器记录</a>
<a href="/2026/03/17/ECS/">ECS 加固记录</a>
</div>
</article>
<article class="project-card">
<h2>DVWA / Burp Suite 学习记录</h2>
<p>通过 Docker、DVWA 和 Burp Suite 复现基础 Web 漏洞，重点记录抓包、参数修改、漏洞触发和修复思路。</p>
<div class="project-meta">
<span>Web 安全</span>
<span>Burp Suite</span>
<span>Docker</span>
<span>靶场复现</span>
</div>
<ul>
<li>搭建 DVWA 靶场并验证基础漏洞。</li>
<li>记录 Burp Suite 抓包和请求修改流程。</li>
<li>把漏洞复现过程整理成学习文章。</li>
</ul>
<div class="project-links">
<a href="/2025/12/31/web-docker-dvwa-bp/">Docker + DVWA + Burp</a>
<a href="/2026/03/25/web-DVWA/">DVWA 学习记录</a>
</div>
</article>
</div>
</section>

<section class="portfolio-section">
<article class="project-card">
<h2>博客源码</h2>
<p>本站基于 Hexo 和 Cactus 主题构建，用来沉淀安全学习、Linux 运维和 CTF 复盘。后续会继续把项目 README、文章和仓库互相链接，形成更完整的作品集。</p>
<div class="project-links">
<a target="_blank" rel="noopener" href="https://github.com/Deng666-dev/Deng666-dev.github.io">博客仓库</a>
<a href="/about/">关于我</a>
<a href="/archives/">全部文章</a>
</div>
</article>
</section>