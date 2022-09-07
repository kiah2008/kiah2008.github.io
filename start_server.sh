#/bin/sh
bundle exec jekyll build && bundle exec jekyll server -H 0.0.0.0 -P 4008 --incremental --watch 