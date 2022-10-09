---
layout: post
title: flask快速搭建个人博客
categories: [web]
tags: [flask, blog]
description: flask快速搭建个人博客
keywords: flask, blog, python
dashang: true
topmost: false
mermaid: false
date:  2022-09-30 16:30:00 +0900
---

个人博客网站使用github+jekyll搭建,虽然已经很满意,不过最近想起自己也是学过一段时间的flask,而且jekyll的模板跟样式跟flask很像,应该是可以很容易将jekyll的个人博客复用到flask,搭建一个动态网站,这样可以有更好的扩展性和互动.

<!-- more -->

# Flask环境搭建

针对flask我们可以透过virtual environment进行环境搭建,主要是安装flask及其依赖库.

## Python环境

```shell
$ python3 -m venv flask_python
```

激活Python环境

- linux
  ```
  $ source flask_python/bin/activate
  (flask_python) $ _
  ```
  
- windows

  ```
  $ flask_python\Scripts\activate
  (flask_python) $ _
  ```

## 安装flask及其依赖库

然后就可以安装flask了， 不过安装前建议升级下pip。

`python -m pip install --upgrade pip`

```
(flask_python) $ pip install flask
```

如果对版本有需求，则可以参考如下命令。

```
(flask_python) $ pip install "flask<2"
```

```
Installing collected packages: MarkupSafe, Jinja2, Werkzeug, itsdangerous, zipp, typing-extensions, importlib-metadata, colorama, click, flask
Successfully installed Jinja2-3.1.2 MarkupSafe-2.1.1 Werkzeug-2.2.2 click-8.1.3 colorama-0.4.5 flask-2.2.2 importlib-metadata-4.12.0 itsdangerous-2.1.2 typing-extensions-4.3.0 zipp-3.8.1
```

安装成功后，可以尝试导入`flask`测试下是否成功安装。

```
(flask_python) D:\programs\python3_venv\flask_python\Scripts>python
Python 3.7.9 (tags/v3.7.9:13c94747c7, Aug 17 2020, 16:30:00) [MSC v.1900 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license" for more information.
>>> import flask
>>>
```

## 使用pycharm进行开发

pycharm是个不错的python集成开发环境，个人用途可以从官网下载社区版。

在pycharm选择settings，然后添加我们刚创建的venv。

![image-20220930165151021](/images/web/flask/image-20220930165151021.png)

## 使用vs code 进行开发

安装微软python插件, 然后选择python编译器路径(刚才创建的flask venv).创建launch 脚本.

```
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python: Flask",
            "type": "python",
            "request": "launch",
            "module": "flask",
            "env": {
                "FLASK_APP": "app.py",
                "FLASK_DEBUG": "1"
            },
            "args": [
                "run",
                "--no-debugger",
                "--no-reload"
            ],
            "jinja": true,
            "justMyCode": true
        }
    ]
}
```

## 启动Flask App

设置FLASK_APP环境变量

- linux

  ```
  (venv) $ export FLASK_APP=microblog.py
  ```

- windows

  ```
  (venv) $ set FLASK_APP=microblog.py
  ```

  > 如果你觉得每次运行app都需要设置环境变量是件繁琐的事情， 可以安装python-dotenv, 这样就可以 *.flaskenv*进行配置。
  >
  > `(venv) $ pip install python-dotenv`

运行flask

`flask run`

```
* Running on http://127.0.0.1:5000
Press CTRL+C to quit
```

然后就可以使用浏览器访问上面网址。

# Error handle

如果指定了FLASK_ENV变量为developmenet, 那么当Flask遇到u错误, 会重定向到错误页面(打印stack trace).

```
(venv) $ export FLASK_ENV=development
```

> 如果是windows 版本, 则需要将export更换为set

![Flask Debugger](/images/web/flask/ch07-debugger.png)

## 定制错误页面

```python
from flask import render_template
from app import app, db

@app.errorhandler(404)
def not_found_error(error):
    return render_template('404.html'), 404

@app.errorhandler(500)
def internal_error(error):
    db.session.rollback()
    return render_template('500.html'), 500
```

## 发送问题邮件

添加邮件账号信息

```python
//config.py: Email configuration
class Config(object):
    # ...
    MAIL_SERVER = os.environ.get('MAIL_SERVER')
    MAIL_PORT = int(os.environ.get('MAIL_PORT') or 25)
    MAIL_USE_TLS = os.environ.get('MAIL_USE_TLS') is not None
    MAIL_USERNAME = os.environ.get('MAIL_USERNAME')
    MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')
    ADMINS = ['your-email@example.com']
```

使用logging模块,将错误日志透过邮件进行发送.

```python
//app/__init__.py: Log errors by email

import logging
from logging.handlers import SMTPHandler

# ...

if not app.debug:
    if app.config['MAIL_SERVER']:
        auth = None
        if app.config['MAIL_USERNAME'] or app.config['MAIL_PASSWORD']:
            auth = (app.config['MAIL_USERNAME'], app.config['MAIL_PASSWORD'])
        secure = None
        if app.config['MAIL_USE_TLS']:
            secure = ()
        mail_handler = SMTPHandler(
            mailhost=(app.config['MAIL_SERVER'], app.config['MAIL_PORT']),
            fromaddr='no-reply@' + app.config['MAIL_SERVER'],
            toaddrs=app.config['ADMINS'], subject='Microblog Failure',
            credentials=auth, secure=secure)
        mail_handler.setLevel(logging.ERROR)
        app.logger.addHandler(mail_handler)
```

如需要测试, 可以使用Python的内置调试邮箱服务器(只是一个假的服务器, 收到邮件并不会进行中转,而是简单的进行打印).

```shell
(venv) $ python -m smtpd -n -c DebuggingServer localhost:8025
```

> 启动smtp服务器后, 记得配置flask的环境变量.

```shell
export MAIL_SERVER=localhost
export MAIL_PORT=8088
export MAIL_USE_TLS=1
export MAIL_USERNAME=<your-mail-username>
export MAIL_PASSWORD=<your-mail-password>
```

## 记录日志到文件

```python
# app/__init__.py: Logging to a file
# ...
from logging.handlers import RotatingFileHandler
import os

# ...

if not app.debug:
    # ...

    if not os.path.exists('logs'):
        os.mkdir('logs')
    file_handler = RotatingFileHandler('logs/microblog.log', maxBytes=10240,
                                       backupCount=10)
    file_handler.setFormatter(logging.Formatter(
        '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'))
    file_handler.setLevel(logging.INFO)
    app.logger.addHandler(file_handler)

    app.logger.setLevel(logging.INFO)
    app.logger.info('Microblog startup')
```



# 数据库设计

Flask没有直接提供sql模块, 而是透过封装[SQLAlchemy](http://www.sqlalchemy.org/)库.它支持SQLITE, MYSQL等SQL Database.可以使用Flask扩展件[Flask-SQLAlchemy](http://packages.python.org/Flask-SQLAlchemy),

```
(venv) $ pip install flask-sqlalchemy
```

## 数据库迁移

主要是解决应用在更新过程中,数据库表格更新,对应数据库内容的更新.

```
(venv) $ pip install flask-migrate
```

### 创建数据库repo

```
(venv) $ flask db init
  Creating directory /home/miguel/microblog/migrations ... done
  Creating directory /home/miguel/microblog/migrations/versions ... done
  Generating /home/miguel/microblog/migrations/alembic.ini ... done
  Generating /home/miguel/microblog/migrations/env.py ... done
  Generating /home/miguel/microblog/migrations/README ... done
  Generating /home/miguel/microblog/migrations/script.py.mako ... done
  Please edit configuration/connection/logging settings in
  '/home/miguel/microblog/migrations/alembic.ini' before proceeding.
```

### 数据库的第一次迁移

```
(venv) $ flask db migrate -m "users table"
INFO  [alembic.runtime.migration] Context impl SQLiteImpl.
INFO  [alembic.runtime.migration] Will assume non-transactional DDL.
INFO  [alembic.autogenerate.compare] Detected added table 'user'
INFO  [alembic.autogenerate.compare] Detected added index 'ix_user_email' on '['email']'
INFO  [alembic.autogenerate.compare] Detected added index 'ix_user_username' on '['username']'
  Generating /home/miguel/microblog/migrations/versions/e517276bb1c2_users_table.py ... done
```

The `flask db migrate` command does not make any changes to the database, it just generates the migration script. To apply the changes to the database, the `flask db upgrade` command must be used.

```
(venv) $ flask db upgrade
INFO  [alembic.runtime.migration] Context impl SQLiteImpl.
INFO  [alembic.runtime.migration] Will assume non-transactional DDL.
INFO  [alembic.runtime.migration] Running upgrade  -> e517276bb1c2, users table
```

https://ondras.zarovi.cz/sql/demo/

### Shell Context

如果我们想在shell命令下执行/调试python代码,会先需要导入依赖库, 写一堆的import,然后进行初始化, 比如下面:

```python
>>> from app import db
>>> from app.models import User, Post
>>> u = User(username='john', email='john@example.com')
>>> db.session.add(u)
>>> db.session.commit()
```

不过实际上透过shell上下文处理器, 我们可以将代码进行简化.

```python
@app.shell_context_processor
def make_shell_context():
    return {'db': db, 'User': User, 'Post': Post}
```

上面我们在shell的上下文提供了db实例和User/Post两个类.

上面导入包的流程就可以简化成一条命令.

> flask shell

运行结果如下:

```
>>> u = User(username='john', email='john@example.com')
>>> db.session.add(u)
>>> db.session.commit()
>>> usrs=User.query.all()
>>> for u in usrs:
...     print(u)
... 
<User kian>
```

## Database CRUD



# BluePrint



# Commands



# 全文搜索

全文搜索引擎, 主要有[Elasticsearch](https://www.elastic.co/products/elasticsearch), [Apache Solr](http://lucene.apache.org/solr/), [Whoosh](http://whoosh.readthedocs.io/), [Xapian](https://xapian.org/), [Sphinx](http://sphinxsearch.com/)等,部分数据库也是支持搜索功能,比如SQLIte,MySQL,PostGreSQL, [MongoDB](https://www.mongodb.com/)等.

## ElasticSearch

### Installing Elasticsearch

- 安装[elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/install-elasticsearch.html)

- 安装python wrapper

  `(venv) $ pip install elasticsearch`

## ElasticSearch操作

elasticsearch的数据主要是一些索引数据, 区别与SQL数据库存,elasticsearch使用了json对象进行存储.

```python
>>> from elasticsearch import Elasticsearch
>>> es = Elasticsearch('http://localhost:9200')
# store on doc to index 'my_index'
>>> es.index(index='my_index', id=1, body={'text': 'this is a test'})
# search from my_index
>>> es.search(index='my_index', body={'query': {'match': {'text': 'this test'}}})
```

搜索结果如下:

```
{
    'took': 309,
    'timed_out': False,
    '_shards': {'total': 1, 'successful': 5, 'skipped': 0, 'failed': 0},
    'hits': {
        'total': {'value': 2, 'relation': 'eq'},
        'max_score': 0.82713,
        'hits': [
            {
                '_index': 'my_index',
                '_type': '_doc',
                '_id': '1',
                '_score': 0.82713,
                '_source': {'text': 'this is a test'}
            },
            {
                '_index': 'my_index',
                '_type': '_doc',
                '_id': '2',
                '_score': 0.1936807,
                '_source': {'text': 'a second test'}
            }
        ]
    }
}
```

## Searchable model

```python
##app/search.py: Search functions.
from flask import current_app

# create `index` from model
def add_to_index(index, model):
    if not current_app.elasticsearch:
        return
    payload = {}
    for field in model.__searchable__:
        payload[field] = getattr(model, field)
    current_app.elasticsearch.index(index=index, id=model.id, body=payload)

def remove_from_index(index, model):
    if not current_app.elasticsearch:
        return
    current_app.elasticsearch.delete(index=index, id=model.id)

def query_index(index, query, page, per_page):
    if not current_app.elasticsearch:
        return [], 0
    search = current_app.elasticsearch.search(
        index=index,
        body={'query': {'multi_match': {'query': query, 'fields': ['*']}},
              'from': (page - 1) * per_page, 'size': per_page})
    ids = [int(hit['_id']) for hit in search['hits']['hits']]
    return ids, search['hits']['total']['value']
```

## 使用SQLAlchemy进行搜索

```python
#app/models.py: SearchableMixin class.
from app.search import add_to_index, remove_from_index, query_index

class SearchableMixin(object):
    @classmethod
    def search(cls, expression, page, per_page):
        ids, total = query_index(cls.__tablename__, expression, page, per_page)
        if total == 0:
            return cls.query.filter_by(id=0), 0
        when = []
        for i in range(len(ids)):
            when.append((ids[i], i))
        return cls.query.filter(cls.id.in_(ids)).order_by(
            db.case(when, value=cls.id)), total

    @classmethod
    def before_commit(cls, session):
        session._changes = {
            'add': list(session.new),
            'update': list(session.dirty),
            'delete': list(session.deleted)
        }

    @classmethod
    def after_commit(cls, session):
        for obj in session._changes['add']:
            if isinstance(obj, SearchableMixin):
                add_to_index(obj.__tablename__, obj)
        for obj in session._changes['update']:
            if isinstance(obj, SearchableMixin):
                add_to_index(obj.__tablename__, obj)
        for obj in session._changes['delete']:
            if isinstance(obj, SearchableMixin):
                remove_from_index(obj.__tablename__, obj)
        session._changes = None

    @classmethod
    def reindex(cls):
        for obj in cls.query:
            add_to_index(cls.__tablename__, obj)

db.event.listen(db.session, 'before_commit', SearchableMixin.before_commit)
db.event.listen(db.session, 'after_commit', SearchableMixin.after_commit)
```

## 使用get方法进行搜索

```python
#app/main/forms.py: Search form.
from flask import request

class SearchForm(FlaskForm):
    q = StringField(_l('Search'), validators=[DataRequired()])

    def __init__(self, *args, **kwargs):
        if 'formdata' not in kwargs:
            kwargs['formdata'] = request.args
        if 'meta' not in kwargs:
            kwargs['meta'] = {'csrf': False}
        super(SearchForm, self).__init__(*args, **kwargs)
```

对于使用get, 需要特别处理csrf(需要放行), 另外就是formdata, 如果是get的话, 就需要将request.args作为赋值数据.

因为SearchForm对于所有页面都是有需求的,所以需要进行存储.

```python
from flask import g
from app.main.forms import SearchForm

@bp.before_app_request
def before_request():
    if current_user.is_authenticated:
        current_user.last_seen = datetime.utcnow()
        db.session.commit()
        g.search_form = SearchForm()
    g.locale = str(get_locale())
```

`g`是flask预制变量, 用来在处理请求期间,存储全局变量.`g`是请求相关的,也即不同请求其内容取决于具体的request.

```
<!-- app/templates/base.html: Render the search form in the navigation bar.-->
...
<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
    <ul class="nav navbar-nav">
        ... home and explore links ...
    </ul>
    {/% if g.search_form %/}
    <form class="navbar-form navbar-left" method="get"
            action="{/{ url_for('main.search') }}">
        <div class="form-group">
            {/{ g.search_form.q(size=20, class='form-control',
                placeholder=g.search_form.q.label.text) }}
        </div>
    </form>
    {/% endif %/}
    ...
```

## search处理函数

```python
@bp.route('/search')
@login_required
def search():
    if not g.search_form.validate():
        return redirect(url_for('main.explore'))
    page = request.args.get('page', 1, type=int)
    posts, total = Post.search(g.search_form.q.data, page,
                               current_app.config['POSTS_PER_PAGE'])
    next_url = url_for('main.search', q=g.search_form.q.data, page=page + 1) \
        if total > page * current_app.config['POSTS_PER_PAGE'] else None
    prev_url = url_for('main.search', q=g.search_form.q.data, page=page - 1) \
        if page > 1 else None
    return render_template('search.html', title=_('Search'), posts=posts,
                           next_url=next_url, prev_url=prev_url)
```

对于post请求, 正常流程会使用`form.validate_on_submit()`, 而应为search使用get方法,所以需要使用`g.search_form.validate()`.

## search result template

*app/templates/search.html*: Search results template.

```
{/% extends "base.html" %/}

{/% block app_content %/}
    <h1>{/{ _('Search Results') }}</h1>
    {/% for post in posts %/}
        {/% include '_post.html' %/}
    {/% endfor %/}
    <nav aria-label="...">
        <ul class="pager">
            <li class="previous{/% if not prev_url %/} disabled{/% endif %/}">
                <a href="{/{ prev_url or '#' }}">
                    <span aria-hidden="true">&larr;</span>
                    {/{ _('Previous results') }}
                </a>
            </li>
            <li class="next{/% if not next_url %/} disabled{/% endif %/}">
                <a href="{/{ next_url or '#' }}">
                    {/{ _('Next results') }}
                    <span aria-hidden="true">&rarr;</span>
                </a>
            </li>
        </ul>
    </nav>
{/% endblock %/}
```

透过`{/% block app_content %/}` override app_content 内容(注意, 如需要保留父模板内容, 需要使用`{/{ super() }}`), 同时使用include 嵌套html

_post.html

```
    <table class="table table-hover">
        <tr>
            <td width="70px">
                <a href="{/{ url_for('main.user', username=post.author.username) }}">
                    <img src="{/{ post.author.avatar(70) }}" />
                </a>
            </td>
            <td>
                {/% set user_link %/}
                    <a href="{/{ url_for('main.user', username=post.author.username) }}">
                        {/{ post.author.username }}
                    </a>
                {/% endset %/}
                {/{ _('%(username)s said %(when)s',
                    username=user_link, when=moment(post.timestamp).fromNow()) }}
                <br>
                <span id="post{/{ post.id }}">{/{ post.body }}</span>
                {/% if post.language and post.language != g.locale %/}
                <br><br>
                <span id="translation{/{ post.id }}">
                    <a href="javascript:translate(
                                '#post{/{ post.id }}',
                                '#translation{/{ post.id }}',
                                '{/{ post.language }}',
                                '{/{ g.locale }}');">{/{ _('Translate') }}</a>
                </span>
                {/%% endif %%/}
            </td>
        </tr>
    </table>

```

# 消息通知

## model定义

创建消息数据库表

```python
# app/models.py: Message model.
class Message(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    sender_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    recipient_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    body = db.Column(db.String(140))
    timestamp = db.Column(db.DateTime, index=True, default=datetime.utcnow)

    def __repr__(self):
        return '<Message {}>'.format(self.body)
```

创建Message table, 定义id\sender_id\recipient_id\body及timestamp字段, 其中timestamp进行index(排序\搜索).

修改user表格

```python
#app/models.py: Private messages support in User model.
class User(UserMixin, db.Model):
    # ...
    messages_sent = db.relationship('Message',
                                    foreign_keys='Message.sender_id',
                                    backref='author', lazy='dynamic')
    messages_received = db.relationship('Message',
                                        foreign_keys='Message.recipient_id',
                                        backref='recipient', lazy='dynamic')
    last_message_read_time = db.Column(db.DateTime)

    # ...

    def new_messages(self):
        last_read_time = self.last_message_read_time or datetime(1900, 1, 1)
        return Message.query.filter_by(recipient=self).filter(
            Message.timestamp > last_read_time).count()
```

创建`User`表,并创建`Message`的relationship， 其中`backref`用于在关系另一端的类中快捷地创建一个指向当前类对象的属性。

## 创建message 表单

```python
#app/main/forms.py: Private message form class.
class MessageForm(FlaskForm):
    message = TextAreaField(_l('Message'), validators=[
        DataRequired(), Length(min=0, max=140)])
    submit = SubmitField(_l('Submit'))
```

## 创建页面

*app/templates/send_message.html*: Send private message HTML template.

```
{/% extends "base.html" %/}
{/% import 'bootstrap/wtf.html' as wtf %/}

{/% block app_content %/}
    <h1>{/{ _('Send Message to %(recipient)s', recipient=recipient) }}</h1>
    <div class="row">
        <div class="col-md-4">
            {/{ wtf.quick_form(form) }}
        </div>
    </div>
{/% endblock %/}
```

## add view function

添加`/send_message/<recipient>` route

```python
#app/main/routes.py: Send private message route.

from app.main.forms import MessageForm
from app.models import Message

# ...

@bp.route('/send_message/<recipient>', methods=['GET', 'POST'])
@login_required
def send_message(recipient):
    user = User.query.filter_by(username=recipient).first_or_404()
    form = MessageForm()
    if form.validate_on_submit():
        msg = Message(author=current_user, recipient=user,
                      body=form.message.data)
        db.session.add(msg)
        db.session.commit()
        flash(_('Your message has been sent.'))
        return redirect(url_for('main.user', username=recipient))
    return render_template('send_message.html', title=_('Send Message'),
                           form=form, recipient=recipient)
```

## Profile添加发送消息链接

```
<!-- app/templates/user.html: Send private message link in user profile page. -->
{/% if user != current_user %/}
<p>
    <a href="{/{ url_for('main.send_message',
             recipient=user.username) }}">
        {/{ _('Send private message') }}
    </a>
</p>
{/% endif %/}
```



# Background jobs

![Task Queue Diagram](/images/web/flask/ch22-queue-diagram.png)

## install [RQ(Redis Queue)](https://github.com/MicrosoftArchive/redis/releases)

> windows推荐使用[memurai](https://www.memurai.com/)

## install rq python package

```
(venv) $ pip install rq
(venv) $ pip freeze > requirements.txt
```



## Task示例

```python
#app/tasks.py: Example background task.

import time

def example(seconds):
    print('Starting task')
    for i in range(seconds):
        print(i)
        time.sleep(1)
    print('Task completed')
```

## 启动task

```shell
(venv) $ rq worker microblog-tasks
18:55:06 RQ worker 'rq:worker:miguelsmac.90369' started, version 0.9.1
18:55:06 Cleaning registries for queue: microblog-tasks
18:55:06
18:55:06 *** Listening on microblog-tasks...
```

## 执行任务

```python
>>> from redis import Redis
>>> import rq
>>> queue = rq.Queue('microblog-tasks', connection=Redis.from_url('redis://'))
>>> job = queue.enqueue('app.tasks.example', 23)
>>> job.get_id()
'c651de7f-21a8-4068-afd5-8b982a6f6d32'
```

## 使用rq task发送邮件

```python
#app/email.py: Send emails with attachments.

# ...

def send_email(subject, sender, recipients, text_body, html_body,
               attachments=None, sync=False):
    msg = Message(subject, sender=sender, recipients=recipients)
    msg.body = text_body
    msg.html = html_body
    if attachments:
        for attachment in attachments:
            msg.attach(*attachment)
    if sync:
        mail.send(msg)
    else:
        Thread(target=send_async_email,
            args=(current_app._get_current_object(), msg)).start()
```

> `attach(*attachement)`表示attachment是一个列表，对应到函数的参数列表（自动展开）， 也即可以使用 `func(*args)` 展开到func的各个参数列表， 取代 `func(args[0], args[1], args[2])`. 

## Task Helpers

如果需要使用flask环境， 则需要先初始化flask app。

```python
#app/tasks.py: Create application and context.

from app import create_app

app = create_app()
app.app_context().push()
```

`app.app_context().push()`确保可以正常使用current_app。

更新task进度

```python
#app/tasks.py: Set task progress.

from rq import get_current_job
from app import db
from app.models import Task

# ...

def _set_task_progress(progress):
    job = get_current_job()
    if job:
        job.meta['progress'] = progress
        job.save_meta()
        task = Task.query.get(job.get_id())
        task.user.add_notification('task_progress', {'task_id': job.get_id(),
                                                     'progress': progress})
        if progress >= 100:
            task.complete = True
        db.session.commit()
```

## 实现导出任务

# 其它

## 环境变量

使用dotenv可以从文件加载环境变量.

```python
import os
from dotenv import load_dotenv
#获取当前文件路径
basedir = os.path.abspath(os.path.dirname(__file__))
load_dotenv(os.path.join(basedir, '.env'))
```



## 依赖库

如果我们需要重新安装python环境, 会需要重新安装依赖库.pip支持当前环境下的依赖库文件, 这样在新的环境下,可以直接透过pip进行安装.

pip生成或是安装requriements

- `pip freeze > requirements.txt`
- `pip install -r requirements.txt`

## current_app介紹

flask内置变量, 线程局部变量,只有响应request的线程才有效. 如需要在不同线程间传递,需要使用current_app._get_current_object().

## flask markdown editor

- [flask-mdeditor](https://github.com/callmehero/flask-mdeditor)

- [flask mde](https://github.com/bittobennichan/Flask-MDE)

- [editormd.js](https://pandao.github.io/editor.md/)

# FAQ

## Flask中, 我们会看到有些import会位于文件尾部,而非推荐的文件开始位置
`
原因是为了避免循环依赖,This import is at the bottom to avoid circular dependencies.
`
