require "rails/generators"

module Notyfhir
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../../app/views", __dir__)
      
      desc "Copy Notyfhir views to your application"
      
      def copy_views
        directory "notyfhir", "app/views/notyfhir"
      end
      
      def show_message
        puts "\n"
        puts "=" * 80
        puts "Notyfhir views copied to app/views/notyfhir"
        puts "You can now customize the views as needed."
        puts "=" * 80
        puts "\n"
      end
    end
  end
end