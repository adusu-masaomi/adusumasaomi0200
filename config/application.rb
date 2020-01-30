require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Adusu
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    # config.time_zone = 'Asia/Tokyo'
    
    #これだと日付で保存するときにエラーが出る・・
    # config.time_zone = 'Asia/Tokyo'

    config.active_record.default_timezone = :local
    #config.active_record.default_timezone = 'Asia/Tokyo'
	
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    #モデルの日本語化ファイルを別管理にする
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]

	# config.i18n.default_locale = :de
    config.i18n.default_locale = :ja 
    
    
    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
     
    #config.assets.enabled=false
    config.assets.enabled=true	
    
    #config.assets.paths << "#{Rails}/app/assets/fonts"
    #config.assets.paths << "#{Rails}/adusu/app/assets/fonts"
    config.assets.paths << "#{Rails}/vendor/assets/fonts"
    #config.assets.paths << Rails.root.join('app','assets','fonts')
    #config.assets.paths << Rails.root.join('app','assets','fonts')
    
    #config.assets.paths << "#{Rails}/app/assets/fonts"
    #config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/ 
    
    config.assets.precompile += %w(*.woff *.eot *.svg *.ttf jquery.tablefix.js cb-materialbtn.min.css) 

    #config.action_controller.relative_url_root = '/sub'
    # for backup
    #config.autoload_paths += %W(#{Rails.root}/lib)
    
  end
end
