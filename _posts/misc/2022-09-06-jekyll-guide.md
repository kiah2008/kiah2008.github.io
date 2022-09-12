---
layout: post
title: 使用Jekyll+github快速搭建个人网站
categories: misc
tags: [jekyll]
description: 使用Jekyll+github快速搭建个人网站
dashang: true
date:  2022-09-09 21:16:00 +0900
keywords: jekyll, github, blog
---

介绍Jekyll基本用法, 使用Jekyll和Github快速上手个人博客搭建.

<!-- more -->

# 目录结构

基本的Jekyll目录结构:

```
.
├── _config.yml
├── _drafts
|   ├── begin-with-the-crazy-ideas.textile
|   └── on-simplicity-in-technology.markdown
├── _includes
|   ├── footer.html
|   └── header.html
├── _layouts
|   ├── default.html
|   └── post.html
├── _posts
|   ├── 2007-10-29-why-every-programmer-should-play-nethack.textile
|   └── 2009-04-26-barcamp-boston-4-roundup.textile
├── _site
├── .jekyll-metadata
└── index.html
```



# 语法

Jekyll 会遍历你的网站搜寻要处理的文件。任何有 [YAML 头信息](http://jekyllcn.com/docs/frontmatter)的文件都是要处理的对象。对于每一个这样的文件，Jekyll 都会通过 [Liquid 模板工具](https://github.com/Shopify/liquid/wiki)来生成一系列的数据。下面就是这些可用数据变量的参考和文档。

## Jekyll 模板、变量

Jekyll 模板实际上分两部分：一部分是头部定义，另一部分是[Liquid 语法](https://github.com/Shopify/liquid/wiki/Liquid-for-Designers)。

### 头部定义

主要用于指定模板(layout)和定义一些变量，比如：标题(title)、描述(description)、标签(tags)、分类(category/categories)、是否发布(published)，以及其他自定义的变量。
```text

---
layout:     post   # 指定使用的模板文件，“_layout” 目录下的模板文件名决定变量名
title:      title  # 文章的标题
date:       date   # 覆盖文章名中的日期
category:   blog   # 文章的类别
description: description
published:  true   # default true 设置 “false” 后，文章不会显示
permalink:  /:categories/:year/:month/:day/:title.html  # 覆盖全局变量设定的文章发布格式
---

```

注意：如果文本文件使用的是`utf-8`编码，那么必须确保文件中不存在`BOM`头部字符，尤其是当 Jekyll 运行在 Windows 平台上。

## Liquid 语法

[Liquid](https://github.com/Shopify/liquid/wiki)是 Ruby 的一个模版引擎库，Jekyll中用到的Liquid标记有两种：**输出**和**标签**。

{% raw %}
- Output 标记：变成文本输出，被2层成对的花括号包住，如：`{{content}}`
- Tag 标记：执行命令，被成对的花括号和百分号包住，如：`{ % command % }`

{% endraw %}

### Jekyll 输出 Output

示例：

{% raw %}
```tex
Hello {{name}}
Hello {{user.name}}
Hello {{ 'tobi' }}
```
{% endraw %}

Output 标记可以使用过滤器 Filters 对输出内容作简单处理。 多个 Filters 间用竖线隔开，从左到右依次执行，Filter 左边总是输入，返回值为下一个 Filter 的输入或最终结果。

{% raw %}

```tex
Hello {{ 'tobi' | upcase }}  # 转换大写输出
Hello tobi has {{ 'tobi' | size }} letters!  # 字符串长度
Hello {{ '*tobi*' | markdownify | upcase }}  # 将Markdown字符串转成HTML大写文本输出
Hello {{ 'now' | date: "%Y %h" }}  # 按指定日期格式输出当前时间
```
{% endraw %}


### 标准过滤器 Filters

下面是常用的过滤器方法，更多的API需要查阅源代码（有注释）才能看到。

源码主要看两个 Ruby Plugin 文件：`filters.rb`(Jekyll) 和`standardfilters.rb`(Liquid)。
------
{% raw %}


- `date`- 将时间戳转化为另一种格式 ([syntax reference](http://docs.shopify.com/themes/liquid-documentation/filters/additional-filters#date))
- `capitalize`- 输入字符串首字母大写 e.g.`{{'capitalize me'|capitalize}}# => 'Capitalize me'`
- `downcase`- 输入字符串转换为小写
- `upcase`- 输入字符串转换为大写
- `first`- 返回数组中第一个元素
- `last`- 返回数组数组中最后一个元素
- `join`- 用特定的字符将数组连接成字符串输出
- `sort`- 对数组元素排序
- `map`- 输入数组元素的一个属性作为参数，将每个元素的属性值映射为字符串
- `size`- 返回数组或字符串的长度 e.g.`{{array|size}}`
- `escape`- 将字符串转义输出 e.g.`{{"<p>test</p>"|escape}}# => <p>test</p>`
- `escape_once`- 返回转义后的HTML文本，不影响已经转义的HTML实体
- `strip_html`- 删除 HTML 标签
- `strip_newlines`- 删除字符串中的换行符(`\n`)
- `newline_to_br`- 用HTML`<br/>`替换换行符`\n`
- `replace`- 替换字符串中的指定内容 e.g.`{{'foofoo'|replace:'foo','bar'}}# => 'barbar'`
- `replace_first`- 查找并替换字符串中第一处找到的目标子串 e.g.`{{'barbar'|replace_first:'bar','foo'}}# => 'foobar'`
- `remove`- 删除字符串中的指定内容 e.g.`{{'foobarfoobar'|remove:'foo'}}# => 'barbar'`
- `remove_first`- 查找并删除字符串中第一处找到的目标子串 e.g.`{{'barbar'|remove_first:'bar'}}# => 'bar'`
- `truncate`- 截取指定长度的字符串，第2个参数追加到字符串的尾部 e.g.`{{'foobarfoobar'|truncate:5,'.'}}# => 'foob.'`
- `truncatewords`- 截取指定单词数量的字符串
- `prepend`- 在字符串前面添加字符串 e.g.`{{'bar'|prepend:'foo'}}# => 'foobar'`
- `append`- 在字符串后面追加字符串 e.g.`{{'foo'|append:'bar'}}# => 'foobar'`
- `slice`- 返回字符子串指定位置开始、指定长度的子串 e.g.`{{"hello"|slice:-4,3}}# => ell`
- `minus`- 减法运算 e.g.`{{4|minus:2}}# => 2`
- `plus`- 加法运算 e.g.`{{'1'|plus:'1'}}#=> '11', {{ 1 | plus:1 }} # => 2`
- `times`- 乘法运算 e.g`{{5|times:4}}# => 20`
- `divided_by`- 除法运算 e.g.`{{10|divided_by:2}}# => 5`
- `split`- 根据匹配的表达式将字符串切成数组 e.g.`{{"a~b"|split:"~"}}# => ['a','b']`
- `modulo`- 求模运算 e.g.`{{7|modulo:4}}# => 3`
{% endraw %}



### Jekyll 标签 Tag

标签用于模板中的执行语句。目前 Jekyll/Liquid 支持的标准标签库有：

|    Tags     |                      说明                       |
| :---------: | :---------------------------------------------: |
| **assign**  |                   为变量赋值                    |
| **capture** |            用捕获到的文本为变量赋值             |
|  **case**   |             条件分支语句 case…when…             |
| **comment** |                    注释语句                     |
|  **cycle**  |  通常用于在某些特定值间循环选择，如颜色、DOM类  |
|   **for**   |                    循环语句                     |
|   **if**    |                  if/else 语句                   |
| **include** | 将另一个模板包进来，模板文件在`_includes`目录中 |
|   **raw**   |       禁用范围内的 Tag 命令，避免语法冲突       |
| **unless**  |                if 语句的否定语句                |

#### 1. Comments

仅起到注释 Liquid 代码的作用。

```tex
We made 1 million dollars {\% comment \\%\} in losses {\% endcomment \\%\} this year.
```


#### 2. Raw

临时禁止执行 Jekyll Tag 命令，在生成的内容里存在冲突的语法片段的情况下很有用。


#### 3. If / Else

条件语句，可以使用关键字有：`if`、`unless`、`elsif`、`else`。


```tex
 \{\% if user \%\}
   Hello \{\{ user.name \}\}
 \{\% endif \%\}

 # Same as above
 \{\% if user != null \%\}
   Hello \{\{ user.name \}\}
 \{\% endif \%\}

 \{\% if user.name == 'tobi' \%\}
   Hello tobi
 \{\% elsif user.name == 'bob' \%\}
   Hello bob
 \{\% endif \%\}

 \{\% if user.name == 'tobi' or user.name == 'bob' \%\}
   Hello tobi or bob
 \{\% endif \%\}

 \{\% if user.name == 'bob' and user.age > 45 \%\}
   Hello old bob
 \{\% endif \%\}

 \{\% if user.name != 'tobi' \%\}
   Hello non-tobi
 \{\% endif \%\}

 # Same as above
 \{\% unless user.name == 'tobi' \%\}
   Hello non-tobi
 \{\% endunless \%\}

 # Check for the size of an array
 \{\% if user.payments == empty \%\}
    you never paid !
 \{\% endif \%\}

 \{\% if user.payments.size > 0  \%\}
    you paid !
 \{\% endif \%\}

 \{\% if user.age > 18 \%\}
    Login here
 \{\% else \%\}
    Sorry, you are too young
 \{\% endif \%\}

 # array = 1,2,3
 \{\% if array contains 2 \%\}
    array includes 2
 \{\% endif \%\}

 # string = 'hello world'
 \{\% if string contains 'hello' \%\}
    string includes 'hello'
 \{\% endif \%\}
```

#### 4. Case 语句

适用于当条件实例很多的情况。

```tex
\{\% case template \%\}
\{\% when 'label' \%\}
     // \{\{ label.title \}\}
\{\% when 'product' \%\}
     // \{\{ product.vendor | link_to_vendor \}\} / \{\{ product.title \}\}
\{\% else \%\}
     // \{\{page_title\}\}
\{\% endcase \%\}
```

#### 5. Cycle

经常需要在相似的任务间选择时，可以使用`cycle`标签。

```tex
\{\% cycle 'one', 'two', 'three' \%\}
\{\% cycle 'one', 'two', 'three' \%\}
\{\% cycle 'one', 'two', 'three' \%\}
\{\% cycle 'one', 'two', 'three' \%\}

# =>

one
two
three
one
```

如果要对循环作分组处理，可以指定分组的名字：

```
\{\% cycle 'group 1': 'one', 'two', 'three' \%\}
\{\% cycle 'group 1': 'one', 'two', 'three' \%\}
\{\% cycle 'group 2': 'one', 'two', 'three' \%\}
\{\% cycle 'group 2': 'one', 'two', 'three' \%\}

# =>
one
two
one
two
```

#### 6. For loops

循环遍历数组：

```tex
\{\% for item in array \%\}
  \{\{ item \}\}
\{\% endfor \%\}
```

循环迭代 Hash散列，`item[0]`是键，`item[1]`是值：

```tex
\{\% for item in hash \%\}
  \{\{ item[0] \}\}: \{\{ item[1] \}\}
\{\% endfor \%\}
```

每个循环周期，提供下面几个可用的变量：

```tex
forloop.length      # => length of the entire for loop
forloop.index       # => index of the current iteration
forloop.index0      # => index of the current iteration (zero based)
forloop.rindex      # => how many items are still left ?
forloop.rindex0     # => how many items are still left ? (zero based)
forloop.first       # => is this the first iteration ?
forloop.last        # => is this the last iteration ?
```

还有几个属性用来限定循环过程：

`limit:int`： 限制循环迭代次数 `offset:int`： 从第n个item开始迭代 `reversed`： 反转循环顺序

```tex
# array = [1,2,3,4,5,6]
\{\% for item in array limit:2 offset:2 \%\}
  \{\{ item \}\}
\{\% endfor \%\}
# results in 3,4

\{\% for item in collection reversed \%\}
  \{\{item\}\}
\{\% endfor \%\}

\{\% for post in site.posts limit:20 \%\}
  \{\{ post.title \}\}
\{\% endfor \%\}
```

允许自定义循环迭代次数，迭代次数可以用常数或者变量说明：

```tex
# if item.quantity is 4...
\{\% for i in (1..item.quantity) \%\}
  \{\{ i \}\}
\{\% endfor \%\}
# results in 1,2,3,4
```

#### 7. Variable Assignment

为变量赋值，用于输出或者其他 Tag：

```tex
\{\% assign index = 1 \%\}
\{\% assign name = 'freestyle' \%\}

\{\% for t in collections.tags \%\}\{\% if t == name \%\}
  <p>Freestyle!</p>
\{\% endif \%\}\{\% endfor \%\}


# 变量是布尔类型
\{\% assign freestyle = false \%\}

\{\% for t in collections.tags \%\}\{\% if t == 'freestyle' \%\}
  \{\% assign freestyle = true \%\}
\{\% endif \%\}\{\% endfor \%\}

\{\% if freestyle \%\}
  <p>Freestyle!</p>
\{\% endif \%\}
```

`capture`允许将大量字符串合并为单个字符串并赋值给变量，而不会输出显示。

```tex
\{\% capture attribute_name \%\}\{\{ item.title | handleize \}\}-\{\{ i \}\}-color\{\% endcapture \%\}

<label for="\{\{ attribute_name \}\}">Color:</label>
<select name="attributes[\{\{ attribute_name \}\}]" id="\{\{ attribute_name \}\}">
  <option value="red">Red</option>
  <option value="green">Green</option>
  <option value="blue">Blue</option>
</select>
```

------

## 其他模板语句

### 字符转义

有时候想输出`{`了，怎么办？ 使用反斜线`\`转义即可

```tex
\{ => {
```

### 格式化时间

```tex
\{\{ site.time | date_to_xmlschema \}\}     # => 2008-11-07T13:07:54-08:00
\{\{ site.time | date_to_rfc822 \}\}        # => Mon, 07 Nov 2008 13:07:54 -0800
\{\{ site.time | date_to_string \}\}        # => 07 Nov 2008
\{\{ site.time | date_to_long_string \}\}   # => 07 November 2008
```

### 代码语法高亮

安装好**pygments.rb**的 gem 组件和 Python 2.x 后，配置文件添加：`highlighter:pygments`，就可以使用语法高亮命令了，支持语言多达 100 种以上。

```tex
\{\% highlight ruby linenos \%\}
# some ruby code
\{\% endhighlight \%\}
```

上面的示例中，使用`highlight`语句来处理代码块；并设定第一个参数`ruby`来指定高亮的语言 Ruby，第二个参数`linenos`来开启显示代码行号的功能。

为了给代码着色，需要配置相应的样式文件，参考[syntax.css](https://github.com/mojombo/tpw/tree/master/css/syntax.css)； 为了更好的显示行号，可以在上面的 CSS 文件添加`.lineno`样式类。

可用的语言识别符缩写，从[**Pygments’ Lexers Page**](http://pygments.org/docs/lexers/)查阅。 如果从 Pygments 的[Supported Languages](http://pygments.org/languages/)清單，能發現明明有列出該語言名稱，而 pygments.rb 确无法识别该语言，這時候必須到[Available Lexers](http://pygments.org/docs/lexers/)查詢；如果在程序語言的說明中有一行“**New in version 1.5.**”，那就表示只要將**Pygments**更新到 1.5 版， 即可支持该程序语言。

### 链接同域内的 post

使用`post_url`Tag 可以自动生成网站内的某个 post 超链接。 这个命令语句以相关 post 的文件名为参数，在引入同域的 post 链接时，非常有用。

```ttexex
# 自动生成某篇文章的链接地址
{\% post_url 2010-07-21-name-of-post \\%\}

# 引入该文章的链接
[Name of Link]({\% post_url 2010-07-21-name-of-post \\%\})
```

### Gist 命令

嵌入 GitHub Gist，也可以指定要显示的 gist 的文件名。

```tex
{\% gist parkr/931c1c8d465a04042403 \\%\}
{\% gist parkr/931c1c8d465a04042403 jekyll-private-gist.markdown \\%\}
```

### 生成摘要

配置文件中设定`excerpt_separator`取值，每篇 post 都会自动截取从开始到这个值间的内容作为这篇文章的摘要`post.excerpt`使用。 如果要禁用某篇文章的摘要，可以在该篇文章的 YAML 头部设定`excerpt_separator:""`。

```tex
{ \% for post in site.posts \\%\}
  <a href="http://alfred-sun.github.io/blog/2015/01/10/jekyll-liquid-syntax-documentation/\{\{ post.url \}\}">\{\{ post.title \}\}</a>
  \{\{ post.excerpt | remove: 'test' \}\}
{ \% endfor \\%\}
```

### 删除 HTML 标签

这个在摘要作为`head`标签里的`meta="description"`内容输出时很有用

```tex
\{\{ post.excerpt | strip_html \}\}
```


### 删除指定文本

过滤器`remove`可以删除变量中的指定内容

```
\{\{ post.url | remove: 'http' \}\}
```

### CGI Escape

通常用于将 URL 中的特殊字符转义为`%xx`形式

```
\{\{ "foo,bar;baz?" | cgi_escape \}\}  # => foo%2Cbar%3Bbaz%3F
```

### 排序

```
# Sort an array. Optional arguments for hashes:
#   1. property name
#   2. nils order ('first' or 'last')

\{\{ site.pages | sort: 'title', 'last' \}\}
```

### 搜索指定 Key

```
# Select all the objects in an array where the key has the given value.
\{\{ site.members | where:"graduation_year","2014" \}\}
```

### To JSON 格式

将 Hash 散列或数组转换为 JSON 格式

```
\{\{ site.data.projects | jsonify \}\}
```

### 序列化

把一个数组变成一个字符串

```
\{\{ page.tags | array_to_sentence_string \}\}  # => foo, bar, and baz
```

### 单词的个数

```
\{\{ page.content | number_of_words \}\}
```

## 内容名字规范

对于博客 post，文件命名规则必须是`YEAR-MONTH-DAY-title.MARKUP`的格式。 使用`rake post`会自动将 post 文件合适命名。

比如：

```
-11-06-memcached-code.md
-11-06-memcached-lib.md
-11-06-sphinx-config-and-use.md
-11-07-memcached-hash-table.md
-11-07-memcached-string-hash.md
```

## 全局(Global)变量

| 变量        | 说明                                                         |
| ----------- | ------------------------------------------------------------ |
| `site`      | 来自`_config.yml`文件，全站范围的信息+配置。详细的信息请参考下文 |
| `page`      | 页面专属的信息 + [YAML 头文件信息](http://jekyllcn.com/docs/frontmatter/)。通过 YAML 头文件自定义的信息都可以在这里被获取。详情请参考下文。 |
| `layout`    | Layout specific information + the [YAML front matter](http://jekyllcn.com/docs/frontmatter/). Custom variables set via the YAML Front Matter in layouts will be available here. |
| `content`   | 被 layout 包裹的那些 Post 或者 Page 渲染生成的内容。但是又没定义在 Post 或者 Page 文件中的变量。 |
| `paginator` | 每当 `paginate` 配置选项被设置了的时候，这个变量就可用了。详情请看[分页](http://jekyllcn.com/docs/pagination/)。 |

## 全站(site)变量

| 变量                        | 说明                                                         |
| --------------------------- | ------------------------------------------------------------ |
| `site.time`                 | 当前时间（运行`jekyll`这个命令的时间点）。                   |
| `site.pages`                | 所有 Pages 的清单。                                          |
| `site.posts`                | 一个按照时间倒序的所有 Posts 的清单。                        |
| `site.related_posts`        | 如果当前被处理的页面是一个 Post，这个变量就会包含最多10个相关的 Post。默认的情况下，相关性是低质量的，但是能被很快的计算出来。如果你需要高相关性，就要消耗更多的时间来计算。用 `jekyll` 这个命令带上 `--lsi` (latent semantic indexing) 选项来计算高相关性的 Post。注意，GitHub 在生成站点时不支持　`lsi`。 |
| `site.static_files`         | [静态文件](http://jekyllcn.com/docs/static-files/)的列表 (此外的文件不会被 Jekyll 和 Liquid 处理。)。每个文件都具有三个属性： `path`， `modified_time` 以及 `extname`。 |
| `site.html_pages`           | ‘site.pages’的子集，存储以‘.html’结尾的部分。                |
| `site.html_files`           | ‘site.static_files’的子集，存储以‘.html’结尾的部分。         |
| `site.collections`          | 一个所有集合（collection）的清单。                           |
| `site.data`                 | 一个存储了 `_data` 目录下的YAML文件数据的清单。              |
| `site.documents`            | 每一个集合（collection）中的全部文件的清单。                 |
| `site.categories.CATEGORY`  | 所有的在 `CATEGORY` 类别下的帖子。                           |
| `site.tags.TAG`             | 所有的在 `TAG` 标签下的帖子。                                |
| `site.[CONFIGURATION_DATA]` | 所有的通过命令行和 `_config.yml` 设置的变量都会存到这个 `site` 里面。 举例来说，如果你设置了 `url: http://mysite.com` 在你的配置文件中，那么在你的 Posts 和 Pages 里面，这个变量就被存储在了 `site.url`。Jekyll 并不会把对 `_config.yml` 做的改动放到 `watch` 模式，所以你每次都要重启 Jekyll 来让你的变动生效。 |

## 页面(page)变量

| 变量              | 说明                                                         |
| ----------------- | ------------------------------------------------------------ |
| `page.content`    | 页面内容的源码。                                             |
| `page.title`      | 页面的标题。                                                 |
| `page.excerpt`    | 页面摘要的源码。                                             |
| `page.url`        | 帖子以斜线打头的相对路径，例子： `/2008/12/14/my-post.html`。 |
| `page.date`       | 帖子的日期。日期的可以在帖子的头信息中通过用以下格式 `YYYY-MM-DD HH:MM:SS` (假设是 UTC), 或者 `YYYY-MM-DD HH:MM:SS +/-TTTT` ( 用于声明不同于 UTC 的时区， 比如 `2008-12-14 10:30:00 +0900`) 来显示声明其他 日期/时间 的方式被改写， |
| `page.id`         | 帖子的唯一标识码（在RSS源里非常有用），比如 `/2008/12/14/my-post` |
| `page.categories` | 这个帖子所属的 Categories。Categories 是从这个帖子的 `_posts` 以上 的目录结构中提取的。举例来说, 一个在 `/work/code/_posts/2008-12-24-closures.md` 目录下的 Post，这个属性就会被设置成 `['work', 'code']`。不过 Categories 也能在 [YAML 头文件信息](http://jekyllcn.com/docs/frontmatter/) 中被设置。 |
| `page.tags`       | 这个 Post 所属的所有 tags。Tags 是在[YAML 头文件信息](http://jekyllcn.com/docs/frontmatter/)中被定义的。 |
| `page.path`       | Post 或者 Page 的源文件地址。举例来说，一个页面在 GitHub 上的源文件地址。 这可以在 [YAML 头文件信息](http://jekyllcn.com/docs/frontmatter/) 中被改写。 |
| `page.next`       | 当前文章在`site.posts`中的位置对应的下一篇文章。若当前文章为最后一篇文章，返回`nil` |
| `page.previous`   | 当前文章在`site.posts`中的位置对应的上一篇文章。若当前文章为第一篇文章，返回`nil` |

##### 提示™: 使用自定义的头信息

任何你自定义的头文件信息都会在 `page` 中可用。 举例来说，如果你在一个 Page 的头文件中设置了 `custom_css: true`， 这个变量就可以这样被取到 `page.custom_css`。

If you specify front matter in a layout, access that via `layout`. For example, if you specify `class: full_page` in a page’s front matter, that value will be available as `layout.class` in the layout and its parents.

## 分页器(Paginator)

| 变量                           | 说明                  |
| ------------------------------ | --------------------- |
| `paginator.per_page`           | 每一页 Posts 的数量。 |
| `paginator.posts`              | 这一页可用的 Posts。  |
| `paginator.total_posts`        | Posts 的总数。        |
| `paginator.total_pages`        | Pages 的总数。        |
| `paginator.page`               | 当前页号。            |
| `paginator.previous_page`      | 前一页的页号。        |
| `paginator.previous_page_path` | 前一页的地址。        |
| `paginator.next_page`          | 下一页的页号。        |
| `paginator.next_page_path`     | 下一页的地址。        |









> [Github+Jekyll 搭建个人网站详细教程](https://www.jianshu.com/p/9f71e260925d)
> [Jekyll cheat sheet](https://cloudcannon.com/community/jekyll-cheat-sheet/)