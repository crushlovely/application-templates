Settings = {
  :name => 'Application'
}
Settings[:paperclip] = YAML.load_file(File.join(Rails.root, 'config', 'paperclip.yml'))[Rails.env].symbolize_keys!
Paperclip.options[:command_path] = Settings[:paperclip][:command_path]
