require "rails/generators"

module Notyfhir
  module Generators
    class PwaGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)
      
      desc "Install PWA support for Notyfhir"
      
      def create_pwa_controller
        template "pwa_controller.rb", "app/controllers/pwa_controller.rb"
      end
      
      def create_manifest_template
        template "manifest.json.erb", "app/views/pwa/manifest.json.erb"
      end
      
      def create_offline_template
        template "offline.html.erb", "app/views/pwa/offline.html.erb"
      end
      
      def add_pwa_routes
        route_content = <<-RUBY
  
  # PWA routes
  get "/manifest", to: "pwa#manifest", as: :pwa_manifest
  get "/offline", to: "pwa#offline", as: :pwa_offline
        RUBY
        
        route route_content
      end
      
      def update_service_worker
        service_worker_path = "app/javascript/notyfhir/service-worker.js"
        if File.exist?(service_worker_path)
          # Backup existing service worker
          copy_file service_worker_path, "app/javascript/notyfhir/service-worker.js.bak"
        end
        
        # Create enhanced service worker with offline support
        template "service-worker-enhanced.js", service_worker_path
      end
      
      def add_manifest_link_to_layout
        if File.exist?("app/views/layouts/application.html.erb")
          inject_into_file "app/views/layouts/application.html.erb", 
                          after: "<%= csrf_meta_tags %>\n" do
            <<-HTML
    <%= tag.link rel: "manifest", href: pwa_manifest_path(format: :json) %>
    
    <!-- PWA Meta Tags -->
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
    <meta name="apple-mobile-web-app-title" content="<%= Rails.application.class.module_parent_name %>">
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="theme-color" content="#000000">
    
    <!-- iOS Icons -->
    <link rel="apple-touch-icon" href="/icon-192.png">
    <link rel="apple-touch-icon" sizes="152x152" href="/icon-152.png">
    <link rel="apple-touch-icon" sizes="180x180" href="/icon-180.png">
    <link rel="apple-touch-icon" sizes="167x167" href="/icon-167.png">
            HTML
          end
        end
      end
      
      def create_default_icons
        template "icons/icon-192.png", "public/icon-192.png"
        template "icons/icon-512.png", "public/icon-512.png"
        template "icons/icon-152.png", "public/icon-152.png"
        template "icons/icon-180.png", "public/icon-180.png"
        template "icons/icon-167.png", "public/icon-167.png"
      end
      
      def update_configuration
        inject_into_file "config/initializers/notyfhir.rb", 
                        before: /^end/ do
          <<-RUBY
  
  # PWA configuration
  config.pwa_enabled = true
  config.app_name = Rails.application.class.module_parent_name
  config.app_short_name = Rails.application.class.module_parent_name
  config.app_description = "#{Rails.application.class.module_parent_name} Progressive Web App"
  config.app_theme_color = "#000000"
  config.app_background_color = "#ffffff"
  config.app_display = "standalone"
  config.app_start_url = "/"
  config.app_scope = "/"
          RUBY
        end
      end
      
      def show_post_install_message
        puts "\n"
        puts "=" * 80
        puts "PWA support has been added to Notyfhir!"
        puts "=" * 80
        puts "\nNext steps:"
        puts "1. Replace the default icons in /public with your app icons"
        puts "2. Customize the PWA settings in config/initializers/notyfhir.rb"
        puts "3. Update the offline page at app/views/pwa/offline.html.erb"
        puts "4. Test your PWA at https://your-domain.com"
        puts "\nPWA Features added:"
        puts "✅ Web App Manifest"
        puts "✅ Service Worker with offline caching"
        puts "✅ iOS PWA support"
        puts "✅ Install prompt support"
        puts "✅ Default app icons"
        puts "\n"
      end
    end
  end
end