---
title: 站内搜索
layout: page
comments: false
---

<div class="search-article" style="margin-top: 20px;">
    <div id="search-form" style="position: relative;">
        <i class="fa fa-search" style="position: absolute; top: 12px; left: 15px; color: #999;"></i>
        <input id="local-search-input" name="q" type="text" placeholder=" 🔍 输入关键词，搜索技术文章..." 
            style="width: 100%; padding: 10px 10px 10px 40px; border: 2px solid #444; border-radius: 5px; background: #222; color: #fff; outline: none; transition: border 0.3s;">
    </div>
    <div id="local-search-result" style="margin-top: 30px; border-top: 1px dashed #444; padding-top: 20px;"></div>
</div>

<script src="https://cdn.jsdelivr.net/npm/jquery@3/dist/jquery.min.js"></script>
<script>
    var searchFunc = function(path, search_id, content_id) {
        'use strict';
        $.ajax({
            url: path,
            dataType: "xml",
            success: function( xmlResponse ) {
                var datas = $( "entry", xmlResponse ).map(function() {
                    return {
                        title: $( "title", this ).text(),
                        content: $("content",this).text(),
                        url: $( "url" , this).text()
                    };
                }).get();
                var $input = document.getElementById(search_id);
                var $resultContent = document.getElementById(content_id);
                $input.addEventListener('input', function(){
                    var str = '<ul class=\"search-result-list\" style=\"list-style: none; padding: 0;\">';
                    var keywords = this.value.trim().toLowerCase().split(/[\s\-]+/);
                    $resultContent.innerHTML = "";
                    if (this.value.trim().length <= 0) {
                        return;
                    }
                    datas.forEach(function(data) {
                        var isMatch = true;
                        var content_index = [];
                        var data_title = data.title.trim().toLowerCase();
                        var data_content = data.content.trim().replace(/<[^>]+>/g,"").toLowerCase();
                        var data_url = data.url;
                        var index_title = -1;
                        var index_content = -1;
                        var first_occur = -1;
                        if(data_title != '' && data_content != '') {
                            keywords.forEach(function(keyword, i) {
                                index_title = data_title.indexOf(keyword);
                                index_content = data_content.indexOf(keyword);
                                if( index_title < 0 && index_content < 0 ){
                                    isMatch = false;
                                } else {
                                    if (index_content < 0) {
                                        index_content = 0;
                                    }
                                    if (i == 0) {
                                        first_occur = index_content;
                                    }
                                }
                            });
                        }
                        if (isMatch) {
                            str += "<li style='margin-bottom: 20px;'><a href='"+ data_url +"' class='search-result-title' style='font-weight: bold; font-size: 1.1em; color: #2bbc8a;'>" + data.title + "</a>";
                            var content = data.content.trim().replace(/<[^>]+>/g,"");
                            if (first_occur >= 0) {
                                var start = first_occur - 20;
                                var end = first_occur + 80;
                                if(start < 0){
                                    start = 0;
                                }
                                if(start == 0){
                                    end = 100;
                                }
                                if(end > content.length){
                                    end = content.length;
                                }
                                var match_content = content.substr(start, end); 
                                keywords.forEach(function(keyword){
                                    var regS = new RegExp(keyword, "gi");
                                    match_content = match_content.replace(regS, "<b style='color: #ff5252;'>"+keyword+"</b>");
                                });
                                str += "<p class=\"search-result\" style='color: #999; font-size: 0.9em; margin-top: 5px;'>" + match_content + "...</p>"
                            }
                            str += "</li>";
                        }
                    });
                    str += "</ul>";
                    $resultContent.innerHTML = str;
                });
            }
        });
    }
    // 调用搜索函数，路径必须对应根目录生成的 search.xml
    searchFunc('/search.xml', 'local-search-input', 'local-search-result');
</script>