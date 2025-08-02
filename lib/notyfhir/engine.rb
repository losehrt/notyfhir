require "rails"
require "web-push"
require "stimulus-rails"
require "turbo-rails"

module Notyfhir
  class Engine < ::Rails::Engine
    isolate_namespace Notyfhir
    
    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
    end
    
    # 自動載入 controllers, models, etc.
    config.autoload_paths += %W[
      #{root}/app/controllers
      #{root}/app/models
      #{root}/app/services
      #{root}/app/helpers
    ]
    
    # Migrations 由 generator 處理，不在 engine 中載入
    
    # 載入 i18n 檔案
    initializer "notyfhir.i18n" do |app|
      app.config.i18n.load_path += Dir[root.join("config", "locales", "**", "*.{rb,yml}")]
    end
    
    # 載入 assets
    initializer "notyfhir.assets" do |app|
      app.config.assets.paths << root.join("app", "assets", "javascripts")
      app.config.assets.paths << root.join("app", "assets", "stylesheets")
      app.config.assets.paths << root.join("app", "javascript")
      app.config.assets.precompile += %w[
        notyfhir/service-worker.js
        notyfhir/badge_controller.js
        notyfhir/install_controller.js
      ]
    end
    
    # 註冊 Stimulus controllers
    initializer "notyfhir.stimulus" do
      Rails.application.config.after_initialize do
        if defined?(Stimulus) && Stimulus.respond_to?(:config)
          # Rails 8+ 使用新的 Stimulus 配置方式
          Stimulus.config.eager_load_controllers << "#{root}/app/javascript/controllers"
        elsif Rails.application.config.respond_to?(:stimulus)
          # Rails 7 及以下版本
          Rails.application.config.stimulus.eager_load_controllers << "#{root}/app/javascript/controllers"
        end
      end
    end
    
    # 設定 importmap
    initializer "notyfhir.importmap", before: "importmap" do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << root.join("app/javascript") if app.config.importmap.respond_to?(:cache_sweepers)
      end
    end
  end
end