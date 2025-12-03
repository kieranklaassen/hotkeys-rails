require "rails/generators"

module HotkeysRails
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    def copy_controller
      copy_file "hotkey_controller.js", "app/javascript/controllers/hotkey_controller.js"
    end

    def copy_stylesheet
      copy_file "hotkey.css", "app/assets/stylesheets/hotkey.css"
    end
  end
end
