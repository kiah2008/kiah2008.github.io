#/bin/sh
#bundle update
#bundle exec jekyll build --trace && JEKYLL_ENV=development bundle exec jekyll server -H 0.0.0.0 -P 4008 --incremental --watch
bundle exec jekyll build && JEKYLL_ENV=development bundle exec jekyll server -H 0.0.0.0 -P 4008 

