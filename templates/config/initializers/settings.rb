Settings({
  :name => 'Application'
})
Settings(YAML.load_file(File.join(Rails.root, 'config', 'paperclip.yml'))[Rails.env])
Paperclip.options[:command_path] = Settings[:paperclip][:command_path]
