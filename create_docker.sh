docker pull jekyll/jekyll
docker run -it --name jekyll_dev -u jekyll -p 8080:4008 -v $(pwd -P):/srv/jekyll/:rw jekyll/jekyll bundle update
