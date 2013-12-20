require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Cx
  class Application < Rails::Application
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    I18n.enforce_available_locales = false
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # FIXME: insecure
    if Rails.env.production?
      Pusher.app_id = '30750'
      Pusher.key = '339899db7460f58950bd'
      Pusher.secret = 'd453d87791622c357d96'
    elsif Rails.env.staging?
      Pusher.app_id = '62188'
      Pusher.key = 'e024a679b66f37d3ed8e'
      Pusher.secret = '7b16b8061cb2e9b7f9ef'
    else
      Pusher.app_id = '59520'
      Pusher.key = 'f432464ea002212eaf37'
      Pusher.secret = 'ca07a14f43e87125afb7'
    end
  end
end
