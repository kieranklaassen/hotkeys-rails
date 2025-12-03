module HotkeysRails
  class Engine < ::Rails::Engine
    initializer "hotkeys_rails.helper" do
      ActiveSupport.on_load(:action_view) do
        include HotkeysRails::Helper
      end
    end
  end
end
