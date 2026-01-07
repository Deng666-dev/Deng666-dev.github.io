---
title: CTF-MISC-common
date: 2025-12-22 14:51:08
categories:
    - CTF
    - CTF-MISC
    - Common
tags:
    - Misc
---
## 头部文件16进制编码

png 文件头：89504E47 0D0A1A0A 0000000D 49484452   文件尾：00000000 49454E44 AE426082
jpg 文件头：FF D8 FF E0 00 10 4A 46 49 46 00 01
gif 文件头：47 49 46 38 39 61（GIF89A）或 47 49 46 38 37 61（GIF87A）    文件尾：00 3B
bmp 文件头：42 4D
psd 文件头：38 42 50 53
TIFF 文件头：49 49 2A 00

mp3 文件头：49 44 33 03 00 00 00 00
wav 文件头：57 41 56 45 或 52 49 46 46
mid 文件头：4D 54 68 64
avi 文件头：41 56 49 20
mov 文件头：00 00 00 20 66 74 79 70 71 74 20 20 20 05 03 00
swf 文件头：46 57 53 08 AC 43 00 00

pyc 文件头：03 F3 0D 0A
MS-Office2003 文件头：D0 CF 11 E0
xml 文件头：3C 3F 78 6D 6C
html 文件头：68 74 6D 6C 3E
CAD (dwg)，文件头：41433130
Rich Text Format (rtf)，文件头：7B5C727466
Email [thorough only] (eml)，文件头：44656C69766572792D646174653A
Outlook Express (dbx)，文件头：CFAD12FEC5FD746F
Outlook (pst)，文件头：2142444E
MS Access (mdb)，文件头：5374616E64617264204A
WordPerfect (wpd)，文件头：FF575043
Postscript (eps.or.ps)，文件头：252150532D41646F6265
Adobe Acrobat (pdf)，文件头：255044462D312E
Quicken (qdf)，文件头：AC9EBD8F
Windows Password (pwl)，文件头：E3828596
Real Audio (ram)，文件头：2E7261FD
Real Media (rm)，文件头：2E524D46
MPEG (mpg)，文件头：000001BA 或 000001B3
Quicktime (mov)，文件头：6D6F6F76
Windows Media (asf)，文件头：3026B2758E66CF11
M4a，文件头：00000018667479704D3441