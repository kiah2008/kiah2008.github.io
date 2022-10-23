---
layout: post
title: Jekyll Ubuntu部署
categories: [web]
tags: [jekyll]
description: Jekyll Ubuntu部署
keywords: jekyll, ubuntu
dashang: true
topmost: false
mermaid: false
date:  2022-10-23 11:00:00 +0900
---

Jekyll 在unbuntu上的快速部署

<!-- more -->

* TOC
{:toc}
## Prerequisites

- A server running Ubuntu 22.04.
- A root password is configured on your server.

## Getting Started

Before starting, it is recommended to update your system with the latest stable version. You can update it with the following command:

```
apt update -y
apt upgrade -y
```

Once your system is up-to-date, install other required dependencies by running the following command:

```
apt install make build-essential curl git tree -y
```

Once all the dependencies are installed, you can proceed to the next step.

## Install Ruby

Jekyll is written in Ruby, so you will need to install it in your system. By default, the Ruby package is included in the Ubuntu default repository.



Run the following command to install Ruby:

```
apt install ruby ruby-dev -y
```

Once the installation is complete, you will need to tell Ruby’s gem package manager to place gems in our user’s home folder.

You can do it by editing the **~/.bashrc** file:

```
nano ~/.bashrc
```

Add the following lines at the end of the file:

```
export GEM_HOME=$HOME/gems
export PATH=$HOME/gems/bin:$PATH
```

Save and close the file, then activate the environment variable with the following command:

```
source ~/.bashrc
```

Next, you can install Jekyll and bundler using the gem command as shown below:

```
gem install jekyll bundler
```

Once the installation is complete, you can proceed to the next step.

## using bundle install

```
source "https://rubygems.org"

gem "jekyll"
gem "jekyll-paginate"
gem "jekyll-feed"
gem "jekyll-sitemap"
gem "jekyll-github-metadata"
gem "jemoji"
gem "yajl-ruby", ">= 1.1.0"
```



## Create a New Website with Jekyll

At this point, Jekyll is installed in your system. Now, run the following command to create a new website named jekyll.example.com:

```
jekyll new jekyll.example.com
```

Once the website is created, you should get the following output:

```
  Bundler: Using jekyll 4.2.2
  Bundler: Fetching jekyll-seo-tag 2.8.0
  Bundler: Fetching jekyll-feed 0.16.0
  Bundler: Installing jekyll-feed 0.16.0
  Bundler: Installing jekyll-seo-tag 2.8.0
  Bundler: Fetching minima 2.5.1
  Bundler: Installing minima 2.5.1
  Bundler: Bundle complete! 7 Gemfile dependencies, 31 gems now installed.
  Bundler: Use `bundle info [gemname]` to see where a bundled gem is installed.Don't run Bundler as root. Bundler can ask for sudo if it is needed, and
  Bundler: installing your bundle as root will break this application for all non-root
  Bundler: users on this machine.
New jekyll site installed in /root/jekyll.example.com. 
```

Next, you list all files and directories created by Jekyll with the following command:

```
tree jekyll.example.com
```

You should get the following output:

```
jekyll.example.com
	404.html
	about.markdown
	_config.yml
	Gemfile
	Gemfile.lock
	index.markdown
	_posts
	2022-09-25-welcome-to-jekyll.markdown

1 directory, 7 files
```

## Start Jekyll Server

First, navigate to the website directory and add the webrick dependency using the following command:

```
cd jekyll.example.com
bundle add webrick
```

Next, start the Jekyll web server by running the following command:

```
jekyll serve --host=0.0.0.0
```

Once the server starts successfully, you should get the following output:

```
Configuration file: /root/jekyll.example.com/_config.yml
            Source: /root/jekyll.example.com
       Destination: /root/jekyll.example.com/_site
 Incremental build: disabled. Enable with --incremental
      Generating... 
       Jekyll Feed: Generating feed for posts
                    done in 0.375 seconds.
 Auto-regeneration: enabled for '/root/jekyll.example.com'
    Server address: http://0.0.0.0:4000/
  Server running... press ctrl-c to stop.
```
