---
title: kali knowledge points
date: 2025-12-22 09:56:20
categories: [kali]
tags: kali
description: 记录 kail 常用命令
---
## 一些命令
图片分离和拼接：convert分离 montage拼接
分解GIF的命令：convert glance.gif flag.png
水平镜像翻转图片：convert -flop reverse.jpg reversed.jpg
垂直镜像翻转图片：convert -flip reverse.jpg reversed.jpg
合成图片的命令：montage flag*.png -tile x1 -geometry +0+0 flag.png
-tile是拼接时每行和每列的图片数，这里用x1，就是只一行
-geometry是首选每个图和边框尺寸，我们边框为0，图照原始尺寸即可

拼图：
#在kali中处理
拉入kali里处理，如果是碎的图片，
先使用 montage *.PNG -tile 12x12 -geometry +0+0 out.png合成一张图片
*.png表示匹配所有图片
-tile表示图片的张数
-geometry +0+0表示每张图片的间距为0
合成后要先查看图片的宽高（宽高要相等，不相等要用PS调整）

gaps智能拼图：
gaps --image=out.png --generation=30 --population=144 --size=30 --save 

--image 指向拼图的路径
--size 拼图块的像素尺寸
--generations 遗传算法的代的数量
--population 个体数量
--verbose 每一代训练结束后展示最佳结果
--save 将拼图还原为图像

gaps --image=flag.jpg --generations=50 --population=180 --size=125 --verbose

-generations 你要迭代多少次
-population 你有多少个小拼图
--size 每张小图，也就是拼图小块的大小
--verbose 实时显示