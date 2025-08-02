# Notyfhir

[![Gem Version](https://badge.fury.io/rb/notyfhir.svg)](https://badge.fury.io/rb/notyfhir)
[![Ruby](https://github.com/losehrt/notyfhir/actions/workflows/main.yml/badge.svg)](https://github.com/losehrt/notyfhir/actions/workflows/main.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A complete Rails engine for PWA push notifications with notification center, Badge API support, and iOS PWA compatibility.

## Features

- 🔔 **Push Notifications** - Web Push API with VAPID support
- 📱 **iOS PWA Support** - Full support for iOS 16.4+ PWA notifications
- 🔢 **Badge API** - Native app badge count synchronization
- 📬 **Notification Center** - Complete UI for viewing and managing notifications
- 🌍 **i18n Support** - Built-in support for multiple languages (zh-TW, en)
- 🎨 **Tailwind CSS** - Beautiful, responsive UI components
- ⚡ **Hotwire Integration** - Turbo Streams for real-time updates
- 🔧 **Easy Installation** - Rails generator for quick setup

## Requirements

- Rails 7.0+
- Ruby 3.1+
- Stimulus and Turbo (Hotwire)
- Tailwind CSS (for default styling)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'notyfhir'
```

And then execute:

```bash
$ bundle install
```

## Setup

### 1. Run the installation generator

```bash
$ rails generate notyfhir:install
```

This will:
- Create initializer file
- Copy migrations
- Add routes
- Update User model with associations
- Register JavaScript controllers
- Copy locale files

### 2. Generate VAPID keys

```bash
$ rails generate notyfhir:vapid_keys
```

Add the generated keys to your Rails credentials:

```bash
$ rails credentials:edit
```

```yaml
vapid:
  public_key: your_public_key_here
  private_key: your_private_key_here
```

Or use environment variables:
```bash
VAPID_PUBLIC_KEY=your_public_key_here
VAPID_PRIVATE_KEY=your_private_key_here
```

### 3. Configure User model

If the installer couldn't find your User model, add these associations manually:

```ruby
class User < ApplicationRecord
  # Notyfhir associations
  has_many :notyfhir_notifications, class_name: "Notyfhir::Notification", dependent: :destroy
  has_many :notyfhir_push_subscriptions, class_name: "Notyfhir::PushSubscription", dependent: :destroy
end
```

### 4. Run migrations

```bash
$ rails db:migrate
```

### 5. Add notification icon to your navigation

```erb
<%= notyfhir_notification_icon %>
```

Or with custom styling:

```erb
<%= notyfhir_notification_icon(current_user, class: "custom-class") %>
```

## Usage

### Sending Notifications

```ruby
# Send notification to a user
Notyfhir::WebPushService.send_notification(
  user,
  title: "New Message",
  body: "You have a new message from John",
  icon: "/custom-icon.png", # optional
  badge: "/custom-badge.png", # optional
  data: { url: "/messages/123" } # optional custom data
)
```

### Accessing Notifications

Users can access their notifications at:
- `/notyfhir/notifications` - Notification center
- `/notyfhir/notification_settings` - Push notification settings

### Notification Model

```ruby
# Get user's notifications
user.notyfhir_notifications

# Unread notifications
user.notyfhir_notifications.unread

# Mark as read
notification.mark_as_read!
```

### Custom Configuration

```ruby
# config/initializers/notyfhir.rb
Notyfhir.configure do |config|
  # User configuration
  config.user_class_name = "User"
  config.current_user_method = :current_user
  
  # Notification icons
  config.notification_icon = "/icon-192.png"
  config.notification_badge = "/icon-192.png"
  
  # Service Worker path
  config.service_worker_path = "/service-worker"
end
```

## iOS PWA Support

For iOS devices (16.4+), users need to:
1. Add the web app to their home screen
2. Open the app from home screen
3. Enable notifications in the app

The gem automatically detects iOS devices and shows appropriate instructions.

## Badge API

The gem automatically manages app badge counts:
- Updates badge when new notifications arrive
- Clears badge when notifications are read
- Syncs badge count across all open tabs

## Styling

The gem uses Tailwind CSS classes by default. You can override the views by copying them to your application:

```bash
$ rails generate notyfhir:views
```

## Localization

Built-in support for:
- Traditional Chinese (zh-TW)
- English (en)

Add your own translations by creating locale files:

```yaml
# config/locales/notyfhir.fr.yml
fr:
  notyfhir:
    notifications:
      title: "Centre de notifications"
      # ...
```

## Service Worker

The gem provides a service worker that handles:
- Push notification display
- Badge count management
- Notification click handling

The service worker is automatically registered and served at `/service-worker`.

## Troubleshooting

### Notifications not working on iOS

- Ensure iOS version is 16.4 or higher
- App must be installed to home screen
- Open app from home screen (not Safari)

### Badge not updating

- Check if browser supports Badge API
- Ensure service worker is registered
- Check browser console for errors

### Push notifications not receiving

- Verify VAPID keys are correctly configured
- Check if user has granted notification permission
- Ensure service worker is active

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/losehrt/notyfhir.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

Created by losehrt
