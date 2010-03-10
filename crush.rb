@application_name =  File.basename(@root)
@base_uri = "http://github.com/crushlovely/application-templates/raw/master/"

[:general, :database, :cms, :testing, :deployment].each do |template|
  load_template("#{@base_uri}#{template}.rb")
end