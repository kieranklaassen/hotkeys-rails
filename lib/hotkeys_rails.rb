require_relative "hotkeys_rails/version"
require_relative "hotkeys_rails/helper"
require_relative "hotkeys_rails/engine" if defined?(Rails::Engine)

module HotkeysRails
  class Error < StandardError; end
end
