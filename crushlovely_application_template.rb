# Let's get the application name
application_name =  File.basename(@root)

git :init

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

# Create development and test databases
rake "db:create:all"

# Generate a home page controller/action and setup the route for it
generate(:controller, "Home index")
route "map.root :controller => 'home'"

# TODO Extract deploy files into separate files that get pulled down by curl
gem 'boomdesigngroup-crushserver', :version => '>= 0.1', :lib => 'crushserver',  :source => 'http://gems.github.com'
capify!
file "config/deploy.rb", %{set :stages, %w(staging live)
require 'capistrano/ext/multistage'
require 'railsmachine/recipes'
require 'crushserver/recipes'

set :application, "#{application_name}"

# Target directory for the application on the web and app servers.
set :deploy_to, "/var/www/apps/\#{application}"

# Login user for ssh.
set :user, "deploy"
set :runner, user
set :admin_runner, user
set :app_server, :passenger

# =============================================================================
# GIT OPTIONS
# =============================================================================
set :scm, "git"
set :repository,  "git@github.com:boomdesigngroup/\#{application}.git"
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

git :add => "."
git :commit => "-a -m 'Added deployment recipe.'"


if yes?('Apply usual plugin and gem dependencies?')
  # Plugins, gems, etc.
  plugin 'acts_as_list', :git => 'git://github.com/rails/acts_as_list.git', :submodule => true
  plugin 'asset_packager', :git => 'git://github.com/sbecker/asset_packager.git', :submodule => true
  plugin 'crushlovely_framework_generator', :git => 'git@github.com:boomdesigngroup/crushlovely-framework-generator.git', :submodule => true
  plugin 'cucumber', :git => 'git://github.com/aslakhellesoy/cucumber.git', :submodule => true
  plugin 'has_visibility', :git => 'git@github.com:boomdesigngroup/has-visibility.git', :submodule => true
  plugin 'object_daddy', :git => 'git://github.com/flogic/object_daddy.git', :submodule => true
  plugin 'paperclip', :git => 'git://github.com/thoughtbot/paperclip.git', :submodule => true
  plugin 'restful_authentication', :git => 'git://github.com/technoweenie/restful-authentication.git', :submodule => true
  plugin 'rspec', :git => 'git://github.com/dchelimsky/rspec.git', :submodule => true
  plugin 'rspec_hpricot_matchers', :git => 'git://github.com/collectiveidea/rspec_hpricot_matchers.git', :submodule => true
  plugin 'rspec_on_rails_matchers', :git => 'git://github.com/joshknowles/rspec-on-rails-matchers.git', :submodule => true
  plugin 'rspec_rails', :git => 'git://github.com/dchelimsky/rspec-rails.git', :submodule => true
  plugin 'seed_fu', :git => 'git://github.com/mbleigh/seed-fu.git', :submodule => true

  gem "rack", :version => '>= 0.9.1'
  gem "rdiscount", :version => '>= 1.3.0'
  gem "rubypants", :version => '>= 0.2.0'
  gem 'mislav-will_paginate', :version => '~> 2.2.3', :lib => 'will_paginate',  :source => 'http://gems.github.com'

  rake("gems:install", :sudo => true)
  generate(:rspec)

  inside ('spec') {
    run "mkdir exemplars"
    # run "rm spec_helper.rb spec.opts rcov.opts"
    # run "curl -sL http://github.com/imajes/rails-template/raw/master/spec_helper.rb > spec_helper.rb"
    # run "curl -sL http://github.com/imajes/rails-template/raw/master/rcov.opts > rcov.opts"
    # run "curl -sL http://github.com/imajes/rails-template/raw/master/spec.opts > spec.opts"
  }

  if yes?('Generate authentication framework?')
    generate(:authenticated, 'User --rspec')
    rake "db:migrate"
    run 'mkdir -p db/fixtures'
    admin_pw = ask('What password would you like to use for the admin CMS user? (must be a string of letters and numbers at least 6 characters in length)')
    fixture_file = "db/fixtures/001_users.rb"
    run "touch #{fixture_file};"
    run "cat > #{fixture_file} << EOF
    User.seed(:login) do |s|
      s.name = 'Crush + Lovely'
      s.login = 'admin@crushlovely.com'
      s.email = 'admin@crushlovely.com'
      s.password = '#{admin_pw}'
      s.password_confirmation = '#{admin_pw}'
    end
    EOF"
    rake "db:seed"
  end

  if yes?('Generate admin framework?')
    generate(:crushlovely_framework)
  end
end

# Remove garbage
run "rm README"
run "rm public/index.html"
run "rm public/images/rails.png"
run "rm public/favicon.ico"
run "rm public/robots.txt"
run "rm -f public/javascripts/*"

# TODO Pull down jQuery
# TODO Pull down Base CSS

# Commit
git :submodule => "init"
git :add => "."
git :commit => "-a -m 'Initial commit.'"

rake("gems:install", :sudo => true)
