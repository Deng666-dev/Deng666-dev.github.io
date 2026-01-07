---
title: Hexo-git-node.js
date: 2025-12-19 17:01:50
tags: hexo 搭建
categories: [开发笔记]
description: Hexo一些随笔
---

# 这里是 hexo 搭建的 Cactus 主题

# 命令
hexo clean 删除本地生成的public文件
hexo g      生成html文件
hexo s      启动预览本地服务器
hexo d      推送到Github中

写入新文章
hexo new "文章标题"
启动预览
hexo cl && hexo s
部署上线
hexo cl && hexo g && hexo d
创建页面
hexo new page categories

# 目录
\Blog\my-blog\ 目录:
_config.yml 站点配置
-config.catus.yml 主题配置
/source/_posts  文章仓库
/source/img/    图床

# Tag Plugins
{% raw %}
```markdown

    多色提示块：
        {% note blue 'fas fa-bullhorn' %}
            普通提示 (blue)：适合写一般说明。
        {% endnote %}

        {% note green 'fas fa-check-circle' %}
            成功提示 (green)：适合写“运行成功”、“配置完成”。
        {% endnote %}

        {% note orange 'fas fa-exclamation-circle' %}
            警告提示 (orange)：适合写“注意点”、“易错点”。
        {% endnote %}

        {% note red 'fas fa-times-circle' %}
            错误提示 (red)：适合写“报错信息”、“危险操作”。
        {% endnote %}

        {% note purple 'fas fa-star' %}
            高亮提示 (purple)：适合写“知识点”、“技巧”。
        {% endnote %}

    行内高亮标签：
        这是普通文字，但是 {% label blue @Vodka %} 是蓝色的，{% label red @Bug %} 是红色的。
        
    选项卡：
        {% tabs 编程语言对比 %}
        ```python
        print("Hello Vodka")
        '''c++
        count << "Hello Vodka" << endl;
        {% endtabs %}

    折叠卡：
        ```markdown
        {% fold 点击查看详细报错日志 %}
            Error: Uncaught Exception...
        (这里有一万行代码)
        {% endfold %}

    图片与相册：
        {% gallery %}
            ![图1说明](/img/1.jpg)
            ![图2说明](/img/2.jpg)
            ![图3说明](/img/3.jpg)
        {% endgallery %}

    时间轴：
        {% timeline %}
            搭建 Hexo 博客，部署到 GitHub。
            配置 Butterfly 主题，添加了看板娘。
            修复了所有 Bug，Vodka 的博客正式上线！
        {% endtimeline %}

    跳转按钮：
        {% btn https://github.com/xxxxx, 访问我的 GitHub, fab fa-github, blue larger %}
        {% btn https://baidu.com, 点击下载源码, fas fa-download, orange %}
        ：链接 按钮文字 图标 颜色+大小

    cs专业图片：
        ```mermaid
        graph TD
            A[开始] --> B{是否有Bug?}
            B -- 有 --> C[找me]
            C --> D[修复Bug]
            D --> B
            B -- 无 --> E[Vodka 开心]
```
{% endraw %}