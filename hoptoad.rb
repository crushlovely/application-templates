gem 'hoptoad_notifier', :version => '2.2.0'
rake("gems:unpack GEM=hoptoad_notifier")
api_key = ask("What is your api key?")
generate("hoptoad --api-key #{api_key}")
