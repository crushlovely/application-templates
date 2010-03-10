git :init if yes?("Is this a new repository?")

# Setup gitignore
file ".gitignore", ".DS_Store
log/*
tmp/*
public/system/*
backups/*"

# Garbage removal
%w(README public/index.html public/images/rails.png).each do |filename|
  run "rm -f #{filename}"
end

file "README.markdown", %{# Application

Tagline

## Rails Setup

This app requires Rails 2.3.5.  You can check to see if you have that by running `gem list | grep "rails"` and seeing if 2.3.5 is included in the list of versions.  If you don't have it, you can install it by running:

    sudo gem install rails --version=2.3.5 --no-ri --no-rdoc

Once you've got Rails installed, run the following commands to get the app setup.

    sudo rake gems:install
    rake db:create

Then just make sure you've added the app via the Passenger Preference Pane so you can access it at a local host address.}

plugin 'asset_packager', :git => 'git://github.com/sbecker/asset_packager.git'
plugin 'meta_tags', :git => 'git://github.com/kpumuk/meta-tags.git'
plugin 'seed_fu', :git => 'git://github.com/mbleigh/seed-fu.git'
plugin 'awesome_backup', :git => 'git://github.com/collectiveidea/awesome-backup.git'

gem 'capistrano',            :version => '2.5.17', :lib => false
gem 'capistrano-ext',        :version => '1.2.1',  :lib => false
gem 'crushserver',           :version => '0.2.2',  :lib => false

rake("gems:install", :sudo => true)
