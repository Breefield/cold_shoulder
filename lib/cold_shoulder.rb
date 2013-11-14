require 'validator'

module ColdShoulder
  if defined?(Rails)
    class Railtie < Rails::Railtie
      config.before_configuration do
        I18n.load_path << File.join(File.dirname(__FILE__), '../', 'locales', 'en.yml')
      end
    end
  end
end