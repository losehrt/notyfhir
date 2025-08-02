# frozen_string_literal: true

require_relative "lib/notyfhir/version"

Gem::Specification.new do |spec|
  spec.name = "notyfhir"
  spec.version = Notyfhir::VERSION
  spec.authors = ["Nickle Cheng"]
  spec.email = ["losehrt@gmail.com"]

  spec.summary = "Rails PWA push notifications with Badge API support"
  spec.description = "A Rails engine for PWA push notifications with complete notification center, Badge API support, and iOS PWA compatibility"
  spec.homepage = "https://github.com/losehrt/notyfhir"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/losehrt/notyfhir"
  spec.metadata["changelog_uri"] = "https://github.com/losehrt/notyfhir/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Rails dependencies
  spec.add_dependency "rails", ">= 7.0"
  spec.add_dependency "web-push", "~> 3.0"
  spec.add_dependency "stimulus-rails", ">= 0.4.0"
  spec.add_dependency "turbo-rails", ">= 0.7.0"
  
  # Development dependencies
  spec.add_development_dependency "rspec-rails", "~> 6.0"
  spec.add_development_dependency "factory_bot_rails", "~> 6.0"
  spec.add_development_dependency "sqlite3", "~> 1.4"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
