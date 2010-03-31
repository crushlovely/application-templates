  plugin 'cms', :git => 'git@github.com:crushlovely/cms.git'
  plugin 'acts_as_list', :git => 'git://github.com/rails/acts_as_list.git'
  plugin 'has_visibility', :git => 'git://github.com/crushlovely/has-visibility.git'
  plugin 'table_helper', :git => 'git://github.com/pluginaweek/table_helper.git'

  gem 'validation_reflection', :version => '0.3.5'
  gem 'formtastic',            :version => '0.9.2'
  gem 'inherited_resources',   :version => '0.9.2'
  gem 'will_paginate',         :version => '2.3.12'
  gem 'cancan',                :version => '1.0.2'
  gem 'authlogic',             :version => '2.1.3'
  gem 'paperclip',             :version => '2.3.1.1'
  gem 'acts_as_markup',        :version => '1.3.3'

  rake("gems:install", :sudo => true)

  generate(:cms_framework)
  route %{map.sign_out 'sign_out', :controller => 'user_sessions', :action => 'destroy'
  map.sign_in 'sign_in', :controller => 'user_sessions', :action => 'new'
  map.resources :user_sessions
}
  rake "db:migrate"
  run 'mkdir -p db/fixtures'
  file "db/fixtures/001_users.rb", %{def file_attachment(filename)
  File.new(File.join(RAILS_ROOT, "db", "fixtures", "files", filename), 'rb')
end

password = "123abc123"

User.seed(:email) do |c|
  c.name = "Crush + Lovely"
  c.email = "admin@crushlovely.com"
  c.password = password
  c.password_confirmation = password
end}
  rake "db:seed_fu"
