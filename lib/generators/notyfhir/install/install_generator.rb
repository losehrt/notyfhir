require "rails/generators"
require "rails/generators/migration"

module Notyfhir
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      
      source_root File.expand_path("templates", __dir__)
      
      desc "Install Notyfhir gem"
      
      def self.next_migration_number(dirname)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end
      
      def create_initializer
        template "notyfhir.rb", "config/initializers/notyfhir.rb"
      end
      
      def copy_migrations
        migration_template "create_notyfhir_notifications.rb", "db/migrate/create_notyfhir_notifications.rb"
        sleep 1 # 確保 migration 時間戳不同
        migration_template "create_notyfhir_push_subscriptions.rb", "db/migrate/create_notyfhir_push_subscriptions.rb"
      end
      
      def copy_locales
        copy_file "zh-TW.yml", "config/locales/notyfhir.zh-TW.yml"
        copy_file "en.yml", "config/locales/notyfhir.en.yml"
      end
      
      def add_routes
        route_content = <<-RUBY
  
  # Notyfhir routes
  mount Notyfhir::Engine => "/notyfhir"
  
  # Service Worker route (must be at root path)
  get "/service-worker", to: "notyfhir/service_worker#show"
        RUBY
        
        route route_content
      end
      
      def add_user_associations
        user_model_path = "app/models/user.rb"
        
        if File.exist?(user_model_path)
          inject_into_class user_model_path, "User" do
            <<-RUBY
  # Notyfhir associations
  has_many :notyfhir_notifications, class_name: "Notyfhir::Notification", dependent: :destroy
  has_many :notyfhir_push_subscriptions, class_name: "Notyfhir::PushSubscription", dependent: :destroy
            RUBY
          end
        else
          say_status :skip, "User model not found at #{user_model_path}", :yellow
          say_status :info, "Please add the following to your User model manually:", :blue
          say <<-MESSAGE

  # Notyfhir associations
  has_many :notyfhir_notifications, class_name: "Notyfhir::Notification", dependent: :destroy
  has_many :notyfhir_push_subscriptions, class_name: "Notyfhir::PushSubscription", dependent: :destroy
          MESSAGE
        end
      end
      
      def add_javascript_controllers
        if File.exist?("app/javascript/controllers/index.js")
          append_to_file "app/javascript/controllers/index.js" do
            <<-JS

// Notyfhir controllers
import NotyfhirBadgeController from "@notyfhir/badge_controller"
application.register("notyfhir--badge", NotyfhirBadgeController)
            JS
          end
        end
      end
      
      def add_service_worker_registration
        if File.exist?("app/views/layouts/application.html.erb")
          inject_into_file "app/views/layouts/application.html.erb", before: "</body>" do
            <<-HTML
  
  <!-- Notyfhir Service Worker Registration -->
  <script>
    if ('serviceWorker' in navigator) {
      window.addEventListener('load', () => {
        navigator.serviceWorker.register('/service-worker')
          .then((registration) => {
            console.log('[Notyfhir] Service Worker registered:', registration);
          })
          .catch((error) => {
            console.error('[Notyfhir] Service Worker registration failed:', error);
          });
      });
    }
  </script>
  
  <!-- Notyfhir Badge Element -->
  <div id="app_badge" data-controller="notyfhir--badge" data-notyfhir--badge-count-value="0"></div>
            HTML
          end
        end
      end
      
      def add_importmap_pins
        if File.exist?("config/importmap.rb")
          append_to_file "config/importmap.rb" do
            <<-RUBY

# Notyfhir
pin "@notyfhir/badge_controller", to: "notyfhir/badge_controller.js"
            RUBY
          end
        end
      end
      
      def generate_vapid_keys
        puts "\n"
        puts "=" * 80
        puts "Generating VAPID keys..."
        puts "=" * 80
        
        invoke "notyfhir:vapid_keys"
      end
      
      def show_post_install_message
        puts "\n"
        puts "=" * 80
        puts "Notyfhir installation complete!"
        puts "=" * 80
        puts "\nNext steps:"
        puts "1. Run 'rails db:migrate' to create the database tables"
        puts "2. Add VAPID keys to your credentials or environment variables"
        puts "3. Add notification icon to your navigation (see README)"
        puts "4. Test push notifications at /notyfhir/notification_settings"
        puts "\n"
      end
    end
  end
end