require "digest/sha1"
seed = 'a22ce9283b29d7d84fa63dc706aa1fbd4cea3566c1eea2e3923393a9be02cdca3982c2d9e63007a2c414d37f714bcc0fc5c3c311fc9adeae464832472df40b64'

file "config/database.yml", "local: &local
  adapter: mysql
  host: localhost
  encoding: utf8
  username: root
  password: 

development:
  database: #{@application_name}_development
  <<: *local

test:
  database: #{@application_name}_test
  <<: *local

staging:
  database: #{@application_name}_staging
  <<: *local

production:
  database: #{@application_name}_production
  username: #{@application_name}
  password: #{Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{seed}")[1..20]}
  <<: *local"

rake "db:drop", :env => "development"
rake "db:create", :env => "development"
