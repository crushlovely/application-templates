# rails test -m http://gist.github.com/66503.txt

run "rm public/index.html"
run "rm -rf log/*"

run ">> config/database.yml"
run "cat > config/database.yml << EOF
local: &local
  adapter: mysql
  host: localhost
  encoding: utf8
  username: root
  password: 

development:
  database: app_development
  <<: *local

test:
  database: app_test
  <<: *local
EOF"
run "cp config/database.yml config/database.yml.sample"

run "touch .gitignore;"
run "cat > .gitignore << EOF
.DS_Store
database.yml
log/*
tmp/*
public/system/*
EOF"

generate(:controller, "Home index")
route "map.root :controller => 'home'"

git :init
git :add => "."
git :commit => "-a -m 'Initial commit'"

plugin 'rspec', :git => 'git://github.com/dchelimsky/rspec.git', :submodule => true
plugin 'rspec_rails', :git => 'git://github.com/dchelimsky/rspec-rails.git', :submodule => true
plugin 'paperclip', :git => 'git://github.com/thoughtbot/paperclip.git', :submodule => true
plugin 'cucumber', :git => 'git://github.com/aslakhellesoy/cucumber.git', :submodule => true
plugin 'object_daddy', :git => 'git://github.com/flogic/object_daddy.git', :submodule => true
plugin 'acts_as_list', :git => 'git://github.com/rails/acts_as_list.git', :submodule => true
plugin 'rspec_on_rails_matchers', :git => 'git://github.com/joshknowles/rspec-on-rails-matchers.git', :submodule => true
plugin 'seed_fu', :git => 'git://github.com/mbleigh/seed-fu.git', :submodule => true
plugin 'rspec_hpricot_matchers', :git => 'git://github.com/collectiveidea/rspec_hpricot_matchers.git', :submodule => true
plugin 'restful_authentication', :git => 'git://github.com/technoweenie/restful-authentication.git', :submodule => true
plugin 'crushlovely_framework_generator', :git => 'git@github.com:boomdesigngroup/crushlovely-framework-generator.git', :submodule => true

gem "rack", :version => '>= 0.9.0'
gem "rubypants", :version => '>= 0.2.0'
gem "rdiscount", :version => '>= 1.3.0'

generate(:rspec)

git :add => "."
git :commit => "-a -m 'Added plugins as submodules.'"

rake("gems:install", :sudo => true)

run "capify ."
git :add => "."
git :commit => "-a -m 'Added Capistrano file.'"

# script/generate authenticated User
# rake db:create:all
# rake db:migrate
# script/runner "User.create(:login => 'admin@crushlovely.com', :email => 'admin@crushlovely.com', :password => '1234', :password_confirmation => '1234')"
# script/generate crushlovely_framework
