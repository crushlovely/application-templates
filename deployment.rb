@application_name =  File.basename(@root)

plugin 'moonshine', :git => 'git://github.com/railsmachine/moonshine.git'
plugin 'moonshine_iptables', :git => 'git://github.com/railsmachine/moonshine_iptables.git'

generate(:moonshine, '--force')

rake("moonshine:gems")

file "config/deploy.rb", %{set :stages, %w(production build staging)
require 'capistrano/ext/multistage'
require 'crushserver/recipes'

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

file "config/deploy/production.rb", %{set :domain, '#{@application_name}.crushserver.com'
set :rails_env, "production"
server domain, :app, :web, :db, :primary => true}

file "config/deploy/staging.rb", %{set :domain, 'staging.#{@application_name}.crushserver.com'
set :rails_env, "staging"
server domain, :app, :web, :db, :primary => true}

file "app/manifests/application_manifest.rb", %{require "\#{File.dirname(__FILE__)}/../../vendor/plugins/moonshine/lib/moonshine.rb"
class ApplicationManifest < Moonshine::Manifest::Rails
  recipe :default_stack
  recipe :iptables
end}