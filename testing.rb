gem 'pickle',                :env => 'test', :version => '>=0.2.1'
gem 'webrat',                :env => 'test', :version => '>=0.6.0',  :lib => false
gem 'database_cleaner',      :env => 'test', :version => '>=0.4.3',  :lib => false
gem 'cucumber-rails',        :env => 'test', :version => '>=0.2.4',  :lib => false
gem 'cucumber',              :env => 'test', :version => '>=0.6.2',  :lib => false
gem 'shoulda',               :env => 'test', :version => '>=2.10.3', :lib => false
gem 'fakeweb',               :env => 'test', :version => '>=1.2.8'
gem 'ffaker',                :env => 'test', :version => '>=0.3.4'
gem 'factory_girl',          :env => 'test', :version => '>=1.2.3'
gem 'rspec-rails',           :env => 'test', :version => '>=1.3.2',  :lib => false
gem 'rspec',                 :env => 'test', :version => '>=1.3.0',  :lib => false

rake("gems:install", :sudo => true)

generate(:cucumber)
generate(:pickle)
