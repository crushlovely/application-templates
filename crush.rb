@application_name =  File.basename(@root)
@base_uri = "http://github.com/crushlovely/application-templates/raw/master/"

load_template("#{@base_uri}general.rb")
load_template("#{@base_uri}database.rb")
load_template("#{@base_uri}templates.rb") if yes?("Would you like to import default html/css/js?")
load_template("#{@base_uri}cms.rb") if yes?("Would you like to configure a CMS?")
load_template("#{@base_uri}testing.rb") if yes?("Would you like to configure a testing framework?")
load_template("#{@base_uri}deployment.rb") if yes?("Would you like to configure a deployment setup?")
load_template("#{@base_uri}hoptoad.rb") if yes?("Would you like to configure hoptoad?")
