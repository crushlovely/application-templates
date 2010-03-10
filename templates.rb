template_location =  "curl -sL #{@base_uri}templates/"

generate(:controller, "Home index")
route "map.root :controller => 'home'"

if yes?('Clean out stylesheets and import foundation CSS?')
  run "rm -f public/stylesheets/*"
  inside('public/stylesheets') {
    %w(application.css foundation.css reset.css).each do |filename|
      run "#{template_location}stylesheets/#{filename} > #{filename}"
    end
  }
end

if yes?('Clean out javascripts and import jQuery?')
  run "rm -f public/javascripts/*"
  inside('public/javascripts') {
    %w(jquery.js jquery.easing.js application.js).each do |filename|
      run "#{template_location}javascripts/#{filename} > #{filename}"
    end
  }
  inside('config') {
    %w(asset_packages.yml).each do |filename|
      run "#{template_location}config/#{filename} > #{filename}"
    end
  }
else
  rake('asset:packager:create_yml')
end

inside('config') {
  %w(paperclip.yml).each do |filename|
    run "#{template_location}config/#{filename} > #{filename}"
  end
}

inside('config/initializers') {
  %w(paperclip.rb).each do |filename|
    run "#{template_location}config/initializers/#{filename} > #{filename}"
  end
}

if yes?('Overwrite application.html.erb?')
  inside('app/views/layouts') {
    %w(application.html.erb).each do |filename|
      run "#{template_location}layouts/#{filename} > #{filename}"
    end
  }
end

if yes?('Overwrite application_helper.rb?')
  inside('app/helpers') {
    %w(application_helper.rb).each do |filename|
      run "#{template_location}helpers/#{filename} > #{filename}"
    end
  }
end
