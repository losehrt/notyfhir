module Notyfhir
  module ApplicationHelper
    def notyfhir_notification_icon(user = current_user, options = {})
      return unless user
      
      unread_count = user.notyfhir_notifications.unread.count
      
      link_to notyfhir.notifications_path, class: options[:class] || "relative text-gray-700 hover:text-gray-900" do
        content_tag(:div, class: "relative") do
          icon = content_tag(:svg, class: "h-6 w-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
            tag(:path, "stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", 
                d: "M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9")
          end
          
          badge = if unread_count > 0
            content_tag(:span, unread_count,
              class: "absolute -top-1 -right-1 inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-white bg-red-600 rounded-full")
          end
          
          icon + badge.to_s
        end
      end
    end
    
    def notyfhir_pwa_meta_tags
      return "" unless Notyfhir.configuration.pwa_enabled
      
      safe_join([
        tag.link(rel: "manifest", href: pwa_manifest_path(format: :json)),
        tag.meta(name: "apple-mobile-web-app-capable", content: "yes"),
        tag.meta(name: "apple-mobile-web-app-status-bar-style", content: "black-translucent"),
        tag.meta(name: "apple-mobile-web-app-title", content: pwa_app_name),
        tag.meta(name: "mobile-web-app-capable", content: "yes"),
        tag.meta(name: "theme-color", content: Notyfhir.configuration.app_theme_color),
        tag.link(rel: "apple-touch-icon", href: "/icon-192.png"),
        tag.link(rel: "apple-touch-icon", sizes: "152x152", href: "/icon-152.png"),
        tag.link(rel: "apple-touch-icon", sizes: "180x180", href: "/icon-180.png"),
        tag.link(rel: "apple-touch-icon", sizes: "167x167", href: "/icon-167.png")
      ], "\n")
    end
    
    def notyfhir_install_prompt_button(options = {})
      return "" unless Notyfhir.configuration.pwa_enabled
      
      button_class = options[:class] || "hidden fixed bottom-4 right-4 bg-blue-600 text-white px-6 py-3 rounded-lg shadow-lg hover:bg-blue-700 transition-colors"
      
      content_tag(:button, 
        options[:text] || t("notyfhir.pwa.install", default: "Install App"),
        id: "notyfhir-install-button",
        class: button_class,
        data: {
          controller: "notyfhir--install",
          action: "click->notyfhir--install#install"
        }
      )
    end
    
    private
    
    def pwa_app_name
      Notyfhir.configuration.app_name || Rails.application.class.module_parent_name
    end
    
    def pwa_manifest_path(options = {})
      return main_app.pwa_manifest_path(options) if main_app.respond_to?(:pwa_manifest_path)
      "/manifest.json"
    end
  end
end