PaperclipConfig = YAML.load_file(File.join(Rails.root, 'config', 'paperclip.yml'))[Rails.env].symbolize_keys!
Paperclip.options[:command_path] = PaperclipConfig[:command_path]
