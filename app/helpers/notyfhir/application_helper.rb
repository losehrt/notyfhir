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
  end
end