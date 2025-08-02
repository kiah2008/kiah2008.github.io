# [AppSearch](https://developer.android.google.cn/develop/ui/views/search/appsearch?hl=zh-cn)
<img width="3192" height="1790" alt="image" src="https://github.com/user-attachments/assets/ba9c7fcb-e908-4ff3-8c89-d875a7bc84c8" />

<img width="3268" height="1776" alt="image" src="https://github.com/user-attachments/assets/7ec0b2c5-e255-473b-9341-6ec629f03327" />


# Lucene

## Lucene基础工作流程

索引的生成分为两个部分：
1. 创建阶段：
添加文档阶段，通过IndexWriter调用addDocument方法生成正向索引文件；
文档添加后，通过flush或merge操作生成倒排索引文件。
2. 搜索阶段：
用户通过查询语句向Lucene发送查询请求；
通过IndexSearch下的IndexReader读取索引库内容，获取文档索引；
得到搜索结果后，基于搜索算法对结果进行排序后返回。
索引创建及搜索流程如下图所示：
<img width="458" height="435" alt="image" src="https://github.com/user-attachments/assets/293dd192-ddb4-455a-8439-9eea65072bc1" />

## 正向索引
Lucene的基础层次结构由索引、段、文档、域、词五个部分组成。正向索引的生成即为基于Lucene的基础层次结构一级一级处理文档并分解域存储词的过程。
<img width="554" height="207" alt="image" src="https://github.com/user-attachments/assets/a63c4060-a60c-4628-aefa-fed3c7f02590" />

索引文件层级关系如图1所示：
- 索引：Lucene索引库包含了搜索文本的所有内容，可以通过文件或文件流的方式存储在不同的数据库或文件目录下。
- 段：一个索引中包含多个段，段与段之间相互独立。由于Lucene进行关键词检索时需要加载索引段进行下一步搜索，如果索引段较多会增加较大的I/O开销，减慢检索速度，因此写入时会通过段合并策略对不同的段进行合并。
- 文档：Lucene会将文档写入段中，一个段中包含多个文档。
- 域：一篇文档会包含多种不同的字段，不同的字段保存在不同的域中。
- 词：Lucene会通过分词器将域中的字符串通过词法分析和语言处理后拆分成词，Lucene通过这些关键词进行全文检索。

## 倒排索引
Lucene全文索引的核心是基于倒排索引实现的快速索引机制。
倒排索引原理如图2所示，倒排索引简单来说就是基于分析器将文本内容进行分词后，记录每个词出现在哪篇文章中，从而通过用户输入的搜索词查询出包含该词的文章。
<img width="554" height="203" alt="image" src="https://github.com/user-attachments/assets/bf0510a2-e3cd-4f4a-ad58-4a5ba3681118" />



# Elastic

# ref
- [rag w/ elastic search](https://www.elastic.co/search-labs/blog/retrieval-augmented-generation-rag)
- [elasticsearch](https://www.cainiaojc.com/elasticsearch/elasticsearch-populate.html)
-  [Lucene](https://www.cnblogs.com/vivotech/p/15031360.html)
