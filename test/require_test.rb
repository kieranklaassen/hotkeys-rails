require "minitest/autorun"
require "minitest/pride"

class RequireTest < Minitest::Test
  def test_require_with_hyphen_loads_gem
    # Unload the gem first if already loaded
    Object.send(:remove_const, :HotkeysRails) if defined?(HotkeysRails)
    $LOADED_FEATURES.reject! { |f| f.include?("hotkeys_rails") || f.include?("hotkeys-rails") }

    # Add lib to load path (simulating gem installation)
    $LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))

    # This should work - matching the hyphenated gem name
    require "hotkeys-rails"

    assert defined?(HotkeysRails), "HotkeysRails module should be defined after require 'hotkeys-rails'"
    assert defined?(HotkeysRails::Helper), "HotkeysRails::Helper should be defined"
    assert defined?(HotkeysRails::VERSION), "HotkeysRails::VERSION should be defined"
  end
end
