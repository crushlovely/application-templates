# rails appname -m http://github.com/crushlovely/application-templates/raw/master/crushlovely_application_template.rb

# Let's get the application name
application_name =  File.basename(@root)

git :init if yes?("Is this a new repository?")

freeze! if yes?("Freeze the latest Rails?")

# Setup database.yml
file "config/database.yml", "local: &local
  adapter: mysql
  host: localhost
  encoding: utf8
  username: root
  password: 

development:
  database: #{application_name}_development
  <<: *local

test:
  database: #{application_name}_test
  <<: *local"
run "cp config/database.yml config/database.yml.sample"

# Setup gitignore
file ".gitignore", ".DS_Store
database.yml
log/*
tmp/*
public/system/*"

rake "db:drop:all" if yes?("Do you want to drop any previously existing databases?")
# Create development and test databases
rake "db:create:all"

# Generate a home page controller/action and setup the route for it
generate(:controller, "Home index")
route "map.root :controller => 'home'"

if yes?("Do you want to capify this project?")
  capify!
  file "config/deploy.rb", %{set :stages, %w(staging live)
require 'capistrano/ext/multistage'
require 'railsmachine/recipes'
require 'crushserver/recipes'

set :application, "#{application_name}"

set :deploy_to, "/var/www/apps/\#{application}"

set :user, "deploy"
set :runner, user
set :admin_runner, user
set :app_server, :passenger

# GIT OPTIONS
set :scm, "git"
set :repository,  "git@github.com:crushlovely/\#{application}.git"
set :ssh_options, { :forward_agent => true }
default_run_options[:pty] = true
set :deploy_via, :remote_cache
set :git_enable_submodules, true
# branch will be set in environment specific file
 
# APACHE OPTIONS
set :apache_default_vhost, false # force use of apache_default_vhost_config
set :apache_default_vhost_conf, "/etc/httpd/conf/default.conf"
set :apache_conf, "/etc/httpd/conf/apps/\#{application}.conf"
set :apache_ctl, "/etc/init.d/httpd"
set :apache_proxy_address, "127.0.0.1"
set :apache_ssl_enabled, false

set :config_files, %w(database.yml)
after 'deploy:update_code', 'bdg:localize:copy_shared_configurations'
after 'deploy:symlink', 'asset:packager:build_all'

on :start do
  `ssh-add`
end
}

  file "config/deploy/live.rb", %{set :domain, "#{application_name}.bdgserver.com"
set :rails_env, "production"
role :web, domain
role :app, domain
role :db,  domain, :primary => true
role :scm, domain
set :apache_server_name, domain
set :branch, "deploy/live"
}

  file "config/deploy/staging.rb", %{set :domain, "#{application_name}.bdgstage.com"
set :rails_env, "production"
role :web, domain
role :app, domain
role :db,  domain, :primary => true
role :scm, domain
set :apache_server_name, domain
set :branch, "deploy/stage"
}
end
# Plugins, gems, etc.
plugin 'acts_as_list', :git => 'git://github.com/rails/acts_as_list.git'
plugin 'asset_packager', :git => 'git://github.com/sbecker/asset_packager.git'
plugin 'has_visibility', :git => 'git://github.com/crushlovely/has-visibility.git'
plugin 'meta_tags', :git => 'git://github.com/kpumuk/meta-tags.git'
plugin 'seed_fu', :git => 'git://github.com/mbleigh/seed-fu.git'

gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com', :version => '~> 2.2.3'
gem 'right_aws'
gem 'thoughtbot-paperclip', :lib => 'paperclip', :source => 'http://gems.github.com', :version => '2.2.8'
gem "rdiscount"
gem "acts_as_markup"

if yes?('Are you gonna get your BDD on?')
  gem 'rspec', :lib => false, :version => '= 1.2.6'
  gem 'rspec-rails', :lib => false, :version => '= 1.2.6'
  gem 'cucumber', :lib => false, :version => '= 0.3.3'
  gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => 'http://gems.github.com', :version => '1.2.1'
  gem 'webrat', :lib => false, :version => '= 0.4.4'
  gem 'nokogiri', :lib => false, :version => '1.2.3'
  rake("gems:install", :sudo => true)
  generate(:rspec)
end

rake("gems:install", :sudo => true)

if yes?('Generate authentication/admin framework?')
  plugin 'restful_authentication', :git => 'git://github.com/technoweenie/restful-authentication.git'
  plugin 'crushlovely_framework_generator', :git => 'git@github.com:crushlovely/crushlovely-framework-generator.git'

  generate(:authenticated, 'User --rspec')
  rake "db:migrate"
  run 'mkdir -p db/fixtures'
  admin_pw = '123abc123'
  file %{db/fixtures/001_users.rb", "def file_attachment(filename)
  File.new(File.join(File.dirname(__FILE__), "files", filename), 'rb')
end

User.seed(:login) do |s|
  s.name = 'Crush + Lovely'
  s.login = 'admin@crushlovely.com'
  s.email = 'admin@crushlovely.com'
  s.password = '#{admin_pw}'
  s.password_confirmation = '#{admin_pw}'
end}
  rake "db:seed"

  generate(:crushlovely_framework)
end

# Garbage removal
%w(README public/index.html public/images/rails.png public/favicon.ico public/robots.txt).each do |filename|
  run "rm -f #{filename}"
end

if yes?('Clean out stylesheets and import foundation CSS?')
  run "rm -f public/stylesheets/*"
  inside('public/stylesheets') {
    %w(application.css foundation.css reset.css).each do |filename|
      run "curl -sL http://github.com/crushlovely/application-templates/raw/master/stylesheets/#{filename} > #{filename}"
    end
  }
end

if yes?('Clean out javascripts and import jQuery?')
  run "rm -f public/javascripts/*"
  inside('public/javascripts') {
    %w(jquery-1.2.6.js jquery.easing.1.3.js jquery.livequery.js application.js).each do |filename|
      run "curl -sL http://github.com/crushlovely/application-templates/raw/master/javascripts/#{filename} > #{filename}"
    end
  }
  inside('config') {
    %w(asset_packages.yml).each do |filename|
      run "curl -sL http://github.com/crushlovely/application-templates/raw/master/config/#{filename} > #{filename}"
    end
  }
else
  rake('asset:packager:create_yml')
end

if yes?('Overwrite application.html.erb?')
  inside('app/views/layouts') {
    %w(application.html.erb).each do |filename|
      run "curl -sL http://github.com/crushlovely/application-templates/raw/master/layouts/#{filename} > #{filename}"
    end
  }
end

if yes?('Overwrite application_helper.rb?')
  inside('app/helpers') {
    %w(application_helper.rb).each do |filename|
      run "curl -sL http://github.com/crushlovely/application-templates/raw/master/helpers/#{filename} > #{filename}"
    end
  }
end

if yes?('Overwrite Sessions controller and view?')
  inside('app/controllers') {
    %w(sessions_controller.rb).each do |filename|
      run "curl -sL http://github.com/crushlovely/application-templates/raw/master/controllers/#{filename} > #{filename}"
    end
  }

  inside('app/views/sessions') {
    %w(new.html.erb).each do |filename|
      run "curl -sL http://github.com/crushlovely/application-templates/raw/master/views/sessions/#{filename} > #{filename}"
    end
  }
end

if yes?("Commit everything?")
  git :submodule => "init"
  git :add => "."
  git :commit => "-a -m 'Initial commit.'"
end