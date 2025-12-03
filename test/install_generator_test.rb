require_relative "test_helper"
require "rails/generators/test_case"
require_relative "../lib/generators/hotkeys_rails/install_generator"

class InstallGeneratorTest < Rails::Generators::TestCase
  tests HotkeysRails::InstallGenerator
  destination File.expand_path("../tmp", __dir__)

  setup do
    prepare_destination
    FileUtils.mkdir_p(File.join(destination_root, "app/javascript/controllers"))
    FileUtils.mkdir_p(File.join(destination_root, "app/assets/stylesheets"))
  end

  def test_copies_controller
    run_generator
    assert_file "app/javascript/controllers/hotkey_controller.js" do |content|
      assert_match(/import { Controller } from "@hotwired\/stimulus"/, content)
      assert_match(/click\(event\)/, content)
      assert_match(/focus\(event\)/, content)
      assert_match(/#shouldHandle/, content)
    end
  end

  def test_copies_stylesheet
    run_generator
    assert_file "app/assets/stylesheets/hotkey.css" do |content|
      assert_match(/kbd \{/, content)
      assert_match(/\.hide-on-touch/, content)
      assert_match(/@media \(any-hover: none\)/, content)
    end
  end
end
