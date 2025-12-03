require "bundler/setup"
Bundler.require(:default)

require "minitest/autorun"
require "minitest/pride"
require "action_view"
require "action_view/test_case"

require_relative "../lib/hotkeys_rails"
