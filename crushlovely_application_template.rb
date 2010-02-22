application_name =  File.basename(@root)
template_location =  yes?("Pull from remote repository?") ? "curl -sL http://github.com/crushlovely/application-templates/raw/master/" : "cat /Users/Shared/Projects/application-templates/"

git :init if yes?("Is this a new repository?")

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
  <<: *local

staging:
  database: #{application_name}_staging
  <<: *local

production:
  database: #{application_name}_production
  <<: *local"

run "cp config/database.yml config/database.yml.sample"

# Setup gitignore
file ".gitignore", ".DS_Store
database.yml
log/*
tmp/*
public/system/*
backups/*"

rake "db:drop:all" if yes?("Do you want to drop any previously existing databases?")
# Create development and test databases
rake "db:create:all"

# Generate a home page controller/action and setup the route for it
generate(:controller, "Home index")
route "map.root :controller => 'home'"

capify!
file "config/deploy.rb", %{set :stages, %w(production build staging)
require 'capistrano/ext/multistage'
require 'crushserver/recipes'

# =============================================================================
# GIT OPTIONS
# =============================================================================
set :scm, :git
set :git_shallow_clone, 1
set :git_enable_submodules, 1
ssh_options[:paranoid] = false
ssh_options[:forward_agent] = true
default_run_options[:pty] = true

after 'moonshine:apply', 'asset:packager:build_all'

on :start do
  `ssh-add`
end}

file "config/deploy/production.rb", %{set :domain, 'production.#{application_name}.com'
set :rails_env, "production"

role :web, domain, :primary => true
role :app, domain, :primary => true
role :db,  domain, :primary => true
role :scm, domain}

file "config/deploy/staging.rb", %{set :domain, 'staging.#{application_name}.com'
set :rails_env, "staging"

role :web, domain, :primary => true
role :app, domain, :primary => true
role :db,  domain, :primary => true
role :scm, domain}

plugin 'acts_as_list', :git => 'git://github.com/rails/acts_as_list.git'
plugin 'asset_packager', :git => 'git://github.com/sbecker/asset_packager.git'
plugin 'crushlovely_framework_generator', :git => 'git@github.com:crushlovely/crushlovely-framework-generator.git'
plugin 'has_visibility', :git => 'git://github.com/crushlovely/has-visibility.git'
plugin 'meta_tags', :git => 'git://github.com/kpumuk/meta-tags.git'
plugin 'moonshine', :git => 'git://github.com/railsmachine/moonshine.git'
plugin 'seed_fu', :git => 'git://github.com/mbleigh/seed-fu.git'
plugin 'awesome_backup', :git => 'git://github.com/collectiveidea/awesome-backup.git'
plugin 'table_helper', :git => 'git://github.com/pluginaweek/table_helper.git'

gem 'hoptoad_notifier',      :version => '2.2.0'
gem 'vestal_versions',       :version => '0.8.3'
gem 'validation_reflection', :version => '0.3.5'
gem 'formtastic',            :version => '0.9.2'
gem 'inherited_resources',   :version => '0.9.2'
gem 'will_paginate',         :version => '2.3.11'
gem 'clearance',             :version => '0.8.7'
gem 'paperclip',             :version => '2.3.1.1'
gem "rubypants",             :version => '0.2.0'
gem 'rdiscount',             :version => '1.5.8'
gem 'acts_as_markup',        :version => '1.3.3'

# gem 'pickle',                :version => '0.2.1'
# gem 'webrat',                :version => '0.6.0', :lib => false
# gem 'database_cleaner',      :version => '0.4.3', :lib => false
# gem 'cucumber-rails',        :version => '0.2.4', :lib => false
# gem 'cucumber',              :version => '0.6.2', :lib => false
# gem 'fakeweb',               :version => '1.2.8'
# gem 'ffaker',                :version => '0.3.4'
# gem 'factory_girl',          :version => '1.2.3'
# gem 'rspec-rails',           :version => '1.3.2', :lib => false
# gem 'rspec',                 :version => '1.3.0', :lib => false

rake("gems:install", :sudo => true)

generate(:moonshine)
rake("moonshine:gems")

if yes?('Generate authentication/admin framework?')
  generate(:clearance)
  # generate(:vestal_versions_migration)
  rake "db:migrate"
  run 'mkdir -p db/fixtures'
  admin_pw = '123abc123'
  file "db/fixtures/001_users.rb", %{def file_attachment(filename)
  File.new(File.join(File.dirname(__FILE__), "files", filename), 'rb')
end

password = '#{admin_pw}'

User.seed(:email) do |c|
  c.email = 'admin@crushlovely.com'
  c.password = password
  c.password_confirmation = password
  c.email_confirmed = true
end}
  rake "db:seed_fu"
  generate(:crushlovely_framework)
end

# Garbage removal
%w(README public/index.html public/images/rails.png).each do |filename|
  run "rm -f #{filename}"
end

if yes?('Clean out stylesheets and import foundation CSS?')
  run "rm -f public/stylesheets/*"
  inside('public/stylesheets') {
    %w(application.css foundation.css reset.css).each do |filename|
      run "#{template_location}stylesheets/#{filename} > #{filename}"
    end
  }
end

if yes?('Clean out javascripts and import jQuery?')
  run "rm -f public/javascripts/*"
  inside('public/javascripts') {
    %w(jquery.js jquery.easing.js application.js).each do |filename|
      run "#{template_location}javascripts/#{filename} > #{filename}"
    end
  }
  inside('config') {
    %w(asset_packages.yml).each do |filename|
      run "#{template_location}config/#{filename} > #{filename}"
    end
  }
else
  rake('asset:packager:create_yml')
end

inside('config') {
  %w(paperclip.yml).each do |filename|
    run "#{template_location}config/#{filename} > #{filename}"
  end
}

inside('config/initializers') {
  %w(paperclip.rb).each do |filename|
    run "#{template_location}config/initializers/#{filename} > #{filename}"
  end
}

if yes?('Overwrite application.html.erb?')
  inside('app/views/layouts') {
    %w(application.html.erb).each do |filename|
      run "#{template_location}layouts/#{filename} > #{filename}"
    end
  }
end

if yes?('Overwrite application_helper.rb?')
  inside('app/helpers') {
    %w(application_helper.rb).each do |filename|
      run "#{template_location}helpers/#{filename} > #{filename}"
    end
  }
end

route %{map.sign_in  'sign_in',
  :controller => 'sessions',
  :action     => 'new'
map.sign_out 'sign_out',
  :controller => 'sessions',
  :action     => 'destroy',
  :method     => :delete
Clearance::Routes.draw(map)
}

if yes?("Commit everything?")
  git :add => "."
  git :commit => "-a -m 'Initial commit.'"
end