# Elchead's website

The website is based on [Hyde](https://github.com/poole/hyde) and powered by [Jekyll](http://jekyllrb.com).

# Local installation

1. Install Ruby and other dependencies:

`sudo apt-get install ruby-full build-essential zlib1g-dev`

2. Configure the gem installation path:

```bash
echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

3. Install Jekyll and Bundler:

`gem install jekyll bundler`

4. Change to project folder and execute:
   `gem install`

# Local execution

To run locally execute:

`bundle exec jekyll serve`
