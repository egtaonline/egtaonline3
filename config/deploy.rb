require 'bundler/capistrano'
load 'config/recipes/base'
load 'config/recipes/foreman'
load 'config/recipes/nginx'
load 'config/recipes/nodejs'
load 'config/recipes/postgresql'
load 'config/recipes/rbenv'
load 'config/recipes/redis'
load 'config/recipes/puma'
load 'deploy/assets'

server 'egtaonline.eecs.umich.edu', :web, :app, :db, primary: true

set :application, 'egtaonline3'
set :user, 'deployment'
set :deploy_to, "/home/#{user}/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :keep_releases, 10

set :scm, 'git'
set :repository,  'git@github.com:egtaonline/egtaonline3.git'
set :branch, 'master'

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :normalize_asset_timestamps, false

set :shared_children, shared_children + %w{public/uploads public/analysis}

after 'deploy', 'deploy:cleanup'
