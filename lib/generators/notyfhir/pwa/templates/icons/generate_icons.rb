#!/usr/bin/env ruby
# This script generates default PWA icons
require 'fileutils'

def create_svg_icon(size)
  <<~SVG
    <svg xmlns="http://www.w3.org/2000/svg" width="#{size}" height="#{size}" viewBox="0 0 #{size} #{size}">
      <rect width="#{size}" height="#{size}" fill="#3B82F6" rx="#{size * 0.15}"/>
      <text x="50%" y="50%" font-family="Arial, sans-serif" font-size="#{size * 0.4}" font-weight="bold" fill="white" text-anchor="middle" dominant-baseline="middle">N</text>
    </svg>
  SVG
end

# Define icon sizes
icon_sizes = {
  'icon-192.svg' => 192,
  'icon-512.svg' => 512,
  'icon-152.svg' => 152,
  'icon-180.svg' => 180,
  'icon-167.svg' => 167
}

# Generate icons
icon_sizes.each do |filename, size|
  File.write(filename, create_svg_icon(size))
  puts "Generated #{filename}"
end