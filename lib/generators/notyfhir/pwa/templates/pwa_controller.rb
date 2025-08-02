class PwaController < ApplicationController
  skip_before_action :authenticate_user!, only: [:manifest, :offline]
  
  def manifest
    render json: {
      name: pwa_config[:app_name],
      short_name: pwa_config[:app_short_name],
      description: pwa_config[:app_description],
      start_url: pwa_config[:app_start_url],
      scope: pwa_config[:app_scope],
      display: pwa_config[:app_display],
      background_color: pwa_config[:app_background_color],
      theme_color: pwa_config[:app_theme_color],
      orientation: "portrait-primary",
      icons: [
        {
          src: "/icon-192.png",
          sizes: "192x192",
          type: "image/png",
          purpose: "any maskable"
        },
        {
          src: "/icon-512.png",
          sizes: "512x512",
          type: "image/png",
          purpose: "any maskable"
        }
      ],
      shortcuts: [
        {
          name: I18n.t("notyfhir.shortcuts.notifications"),
          url: "/notyfhir/notifications",
          description: I18n.t("notyfhir.shortcuts.view_notifications")
        },
        {
          name: I18n.t("notyfhir.shortcuts.settings"),
          url: "/notyfhir/notification_settings",
          description: I18n.t("notyfhir.shortcuts.notification_settings")
        }
      ],
      screenshots: [],
      categories: ["productivity", "utilities"]
    }
  end
  
  def offline
    # Renders the offline page
  end
  
  private
  
  def pwa_config
    {
      app_name: Notyfhir.configuration.app_name || Rails.application.class.module_parent_name,
      app_short_name: Notyfhir.configuration.app_short_name || Rails.application.class.module_parent_name,
      app_description: Notyfhir.configuration.app_description || "#{Rails.application.class.module_parent_name} Progressive Web App",
      app_theme_color: Notyfhir.configuration.app_theme_color || "#000000",
      app_background_color: Notyfhir.configuration.app_background_color || "#ffffff",
      app_display: Notyfhir.configuration.app_display || "standalone",
      app_start_url: Notyfhir.configuration.app_start_url || "/",
      app_scope: Notyfhir.configuration.app_scope || "/"
    }
  end
end