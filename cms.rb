  plugin 'crushlovely_framework_generator', :git => 'git@github.com:crushlovely/crushlovely-framework-generator.git'
  plugin 'acts_as_list', :git => 'git://github.com/rails/acts_as_list.git'
  plugin 'has_visibility', :git => 'git://github.com/crushlovely/has-visibility.git'
  plugin 'table_helper', :git => 'git://github.com/pluginaweek/table_helper.git'

  gem 'validation_reflection', :version => '0.3.5'
  gem 'formtastic',            :version => '0.9.2'
  gem 'inherited_resources',   :version => '0.9.2'
  gem 'will_paginate',         :version => '2.3.11'
  gem 'clearance',             :version => '0.8.8'
  gem 'paperclip',             :version => '2.3.1.1'
  gem "rubypants",             :version => '0.2.0'
  gem 'rdiscount',             :version => '1.6.3'
  gem 'acts_as_markup',        :version => '1.3.3'

  rake("gems:install", :sudo => true)

  generate(:clearance)

  route %{map.sign_in  'sign_in',
    :controller => 'sessions',
    :action     => 'new'
  map.sign_out 'sign_out',
    :controller => 'sessions',
    :action     => 'destroy',
    :method     => :delete
  Clearance::Routes.draw(map)
  }

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
