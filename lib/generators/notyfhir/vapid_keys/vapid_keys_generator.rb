require "rails/generators"

module Notyfhir
  module Generators
    class VapidKeysGenerator < Rails::Generators::Base
      desc "Generate VAPID keys for Web Push"
      
      def generate_keys
        require "web_push"
        
        vapid_key = WebPush.generate_key
        
        puts "\n"
        puts "=" * 80
        puts "VAPID Keys Generated:"
        puts "=" * 80
        puts "\nPublic Key:"
        puts vapid_key.public_key
        puts "\nPrivate Key:"
        puts vapid_key.private_key
        puts "\n"
        puts "Add these to your Rails credentials:"
        puts "rails credentials:edit"
        puts "\nvapid:"
        puts "  public_key: #{vapid_key.public_key}"
        puts "  private_key: #{vapid_key.private_key}"
        puts "\nOr set as environment variables:"
        puts "VAPID_PUBLIC_KEY=#{vapid_key.public_key}"
        puts "VAPID_PRIVATE_KEY=#{vapid_key.private_key}"
        puts "=" * 80
        puts "\n"
      end
    end
  end
end