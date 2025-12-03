require_relative "lib/hotkeys_rails/version"

Gem::Specification.new do |spec|
  spec.name = "hotkeys-rails"
  spec.version = HotkeysRails::VERSION
  spec.authors = ["Kieran Klaassen"]
  spec.email = ["kieran@kieranklaassen.com"]

  spec.summary = "Keyboard shortcuts for Hotwire apps"
  spec.description = "No dependencies. No configuration. Just HTML."
  spec.homepage = "https://github.com/kieranklaassen/hotkeys-rails"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir["*.{md,txt}", "{lib}/**/*"]
  spec.require_path = "lib"

  spec.add_dependency "railties", ">= 7.0"
end
