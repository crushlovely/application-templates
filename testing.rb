gem 'pickle',                :only => :test, :version => '>=0.2.1'
gem 'webrat',                :only => :test, :version => '>=0.6.0',  :lib => false
gem 'database_cleaner',      :only => :test, :version => '>=0.4.3',  :lib => false
gem 'cucumber-rails',        :only => :test, :version => '>=0.2.4',  :lib => false
gem 'cucumber',              :only => :test, :version => '>=0.6.2',  :lib => false
gem 'shoulda',               :only => :test, :version => '>=2.10.3', :lib => false
gem 'fakeweb',               :only => :test, :version => '>=1.2.8'
gem 'ffaker',                :only => :test, :version => '>=0.3.4'
gem 'factory_girl',          :only => :test, :version => '>=1.2.3'
gem 'rspec-rails',           :only => :test, :version => '>=1.3.2',  :lib => false
gem 'rspec',                 :only => :test, :version => '>=1.3.0',  :lib => false

rake("gems:install", :sudo => true)

generate(:cucumber)
generate(:pickle)
