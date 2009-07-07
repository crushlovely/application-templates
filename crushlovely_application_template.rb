# rails appname -m http://github.com/crushlovely/application-templates/raw/master/crushlovely_application_template.rb

application_name =  File.basename(@root)
if yes?("Pull from remote repository?")
  template_location = "curl -sL http://github.com/crushlovely/application-templates/raw/master/"
else
  template_location = "cat ~/Projects/application-templates/"
end

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
public/system/*"

rake "db:drop:all" if yes?("Do you want to drop any previously existing databases?")
# Create development and test databases
rake "db:create:all"

# Generate a home page controller/action and setup the route for it
generate(:controller, "Home index")
route "map.root :controller => 'home'"

if yes?("Do you want to capify this project?")
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

  set :config_files, %w(database.yml)
  after 'moonshine:apply', 'asset:packager:build_all'

  on :start do
    `ssh-add`
  end}

  file "config/deploy/production.rb", %{set :domain, 'production.#{application_name}.com'
  set :rails_env, "production"

  role :web, domain
  role :app, domain
  role :db,  domain, :primary => true
  role :scm, domain}

  file "config/deploy/staging.rb", %{set :domain, 'staging.#{application_name}.com'
  set :rails_env, "staging"

  role :web, domain
  role :app, domain
  role :db,  domain, :primary => true
  role :scm, domain}
end

plugin 'crushlovely_framework_generator', :git => 'git@github.com:crushlovely/crushlovely-framework-generator.git'
plugin 'acts_as_list', :git => 'git://github.com/rails/acts_as_list.git'
plugin 'has_visibility', :git => 'git://github.com/crushlovely/has-visibility.git'
plugin 'meta_tags', :git => 'git://github.com/kpumuk/meta-tags.git'
plugin 'seed_fu', :git => 'git://github.com/mbleigh/seed-fu.git'
plugin 'rspec_on_rails_matchers', :git => 'git://github.com/brandon/rspec-on-rails-matchers.git'
plugin 'hoptoad_notifier', :git => 'git://github.com/thoughtbot/hoptoad_notifier.git'
plugin 'moonshine', :git => 'git://github.com/railsmachine/moonshine.git'
plugin 'asset_packager', :git => 'git://github.com/sbecker/asset_packager.git'
gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com', :version => '~> 2.2.3'
gem 'thoughtbot-clearance', :lib => 'clearance', :source => 'http://gems.github.com', :version => '0.6.6' 
gem 'right_aws'
gem 'thoughtbot-paperclip', :lib => 'paperclip', :source => 'http://gems.github.com', :version => '2.2.8'
gem 'rubypants', :version => '>= 0.2.0'
gem "rdiscount"
gem "acts_as_markup"
gem "mbleigh-acts-as-taggable-on", :source => "http://gems.github.com", :lib => "acts-as-taggable-on"
gem 'faker', :version => '0.3.1'
gem 'rspec', :lib => false, :version => '= 1.2.6'
gem 'rspec-rails', :lib => false, :version => '= 1.2.6'
gem 'cucumber', :lib => false, :version => '= 0.3.3'
gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => 'http://gems.github.com', :version => '1.2.1'
gem 'webrat', :lib => false, :version => '= 0.4.4'
gem 'nokogiri', :lib => false, :version => '1.2.3'
gem 'bmabey-email_spec', :lib => 'email_spec'

rake("gems:install", :sudo => true)
generate(:rspec)
generate(:cucumber)
generate(:moonshine)
rake("moonshine:gems")

# if yes?('Generate authentication/admin framework?')
#   generate(:clearance)
#   rake "db:migrate"
#   run 'mkdir -p db/fixtures'
#   admin_pw = '123abc123'
#   file "db/fixtures/001_users.rb", %{def file_attachment(filename)
#   File.new(File.join(File.dirname(__FILE__), "files", filename), 'rb')
# end
# 
# User.seed(:login) do |s|
#   s.name = 'Crush + Lovely'
#   s.login = 'admin@crushlovely.com'
#   s.email = 'admin@crushlovely.com'
#   s.password = '#{admin_pw}'
#   s.password_confirmation = '#{admin_pw}'
# end}
#   rake "db:seed"
# 
#   generate(:crushlovely_framework)
# end

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
    %w(jquery-1.2.6.js jquery.easing.1.3.js jquery.livequery.js application.js).each do |filename|
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

# if yes?('Overwrite Sessions controller and view?')
#   inside('app/controllers') {
#     %w(sessions_controller.rb).each do |filename|
#       run "#{template_location}controllers/#{filename} > #{filename}"
#     end
#   }
# 
#   inside('app/views/sessions') {
#     %w(new.html.erb).each do |filename|
#       run "#{template_location}views/sessions/#{filename} > #{filename}"
#     end
#   }
# end

if yes?("Commit everything?")
  git :add => "."
  git :commit => "-a -m 'Initial commit.'"
end