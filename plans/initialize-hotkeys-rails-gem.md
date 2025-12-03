# Initialize hotkeys-rails Ruby Gem

## Overview

Keyboard shortcuts for Hotwire apps. No dependencies. No configuration. Just HTML.

Declare shortcuts directly in view templates using `hotkey:` option on Rails helpers. When DOM elements are removed, listeners automatically cleanup through Stimulus lifecycle.

## API Design (from spec)

### Basic Usage

```erb
<%= link_to "Back", root_path, hotkey: :esc %>
<%= button_to "New Card", cards_path, hotkey: :c %>
<%= button_tag "Save", hotkey: :enter %>
```

### Modifier Keys

```erb
<%= button_tag "Save", hotkey: [:ctrl, :enter] %>
<%= link_to "Jump", jump_path, hotkey: [:meta, :j] %>
<%= button_to "Toggle", toggle_path, hotkey: [:shift, :g] %>
```

`:ctrl` automatically binds both Ctrl (Windows/Linux) AND Cmd (Mac).

### Visual Hints

```erb
<%= link_to cards_path, hotkey: :c do %>
  Add a card <%= hotkey_hint(:c) %>
<% end %>
```

### Labels for Tooltips

```erb
<%= button_tag "Save",
      title: "Save (#{hotkey_label(:ctrl, :enter)})",
      hotkey: [:ctrl, :enter] %>
```

### Focus Instead of Click

```erb
<%= text_field_tag :search, data: hotkey(:f, action: :focus) %>
```

### Works with Other Data Attributes

```erb
<%= link_to "Edit", edit_path,
      hotkey: :e,
      data: { turbo_frame: "modal" } %>
```

## Gem Structure

```
hotkeys-rails/
├── lib/
│   ├── hotkeys_rails.rb
│   └── hotkeys_rails/
│       ├── version.rb
│       ├── engine.rb
│       └── helper.rb
├── lib/generators/
│   └── hotkeys_rails/
│       ├── install_generator.rb
│       └── templates/
│           ├── hotkey_controller.js
│           └── hotkey.css
├── hotkeys-rails.gemspec
├── Gemfile
├── Rakefile
└── README.md
```

## Implementation

### `hotkeys-rails.gemspec`

```ruby
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

  spec.files = Dir["*.{md,txt}", "{lib}/**/*"]
  spec.require_path = "lib"

  spec.add_dependency "railties", ">= 7.0"
end
```

### `lib/hotkeys_rails.rb`

```ruby
require_relative "hotkeys_rails/version"
require_relative "hotkeys_rails/helper"
require_relative "hotkeys_rails/engine" if defined?(Rails::Engine)

module HotkeysRails
  class Error < StandardError; end
end
```

### `lib/hotkeys_rails/version.rb`

```ruby
module HotkeysRails
  VERSION = "0.1.0"
end
```

### `lib/hotkeys_rails/engine.rb`

```ruby
module HotkeysRails
  class Engine < ::Rails::Engine
    initializer "hotkeys_rails.helper" do
      ActiveSupport.on_load(:action_view) do
        include HotkeysRails::Helper
      end
    end
  end
end
```

### `lib/hotkeys_rails/helper.rb`

```ruby
module HotkeysRails
  module Helper
    # Returns data attributes for Stimulus hotkey controller
    #
    # hotkey(:esc)
    # # => { controller: "hotkey", action: "keydown.esc@document->hotkey#click" }
    #
    # hotkey(:ctrl, :enter)
    # # => { controller: "hotkey", action: "keydown.ctrl+enter@document->hotkey#click keydown.meta+enter@document->hotkey#click" }
    #
    def hotkey(*keys, action: :click)
      keys = keys.flatten.map(&:to_s)

      actions = if keys.include?("ctrl")
        chord = keys.join("+")
        meta_chord = keys.map { |k| k == "ctrl" ? "meta" : k }.join("+")
        "keydown.#{chord}@document->hotkey##{action} keydown.#{meta_chord}@document->hotkey##{action}"
      else
        "keydown.#{keys.join("+")}@document->hotkey##{action}"
      end

      { controller: "hotkey", action: actions }
    end

    # Platform-aware label for keyboard shortcuts
    #
    # hotkey_label(:ctrl, :enter)
    # # => "⌘Return" on Mac, "Ctrl+Enter" elsewhere
    #
    def hotkey_label(*keys)
      keys.flatten.map do |key|
        case key.to_s
        when "ctrl"  then mac? ? "⌘" : "Ctrl+"
        when "meta"  then mac? ? "⌘" : "Win+"
        when "alt"   then mac? ? "⌥" : "Alt+"
        when "shift" then mac? ? "⇧" : "Shift+"
        when "enter" then mac? ? "Return" : "Enter"
        when "esc"   then "Esc"
        else key.to_s.upcase
        end
      end.join.gsub(/[⌘⌥⇧]\+/, &:chop)
    end

    # Renders <kbd> element with hide-on-touch class
    #
    # hotkey_hint(:ctrl, :s)
    # # => <kbd class="hide-on-touch">⌘S</kbd>
    #
    def hotkey_hint(*keys)
      content_tag(:kbd, hotkey_label(*keys), class: "hide-on-touch")
    end

    def link_to(name = nil, options = nil, html_options = nil, &block)
      html_options, options, name = options, name, block if block_given?
      html_options = extract_hotkey_option(html_options)
      super(name, options, html_options, &block)
    end

    def button_to(name = nil, options = nil, html_options = nil, &block)
      html_options = extract_hotkey_option(html_options)
      super
    end

    def button_tag(content_or_options = nil, options = nil, &block)
      if content_or_options.is_a?(Hash)
        options = extract_hotkey_option(content_or_options)
        super(nil, options, &block)
      else
        options = extract_hotkey_option(options)
        super(content_or_options, options, &block)
      end
    end

    private

    def extract_hotkey_option(html_options)
      return {} if html_options.nil?
      html_options = html_options.dup

      if hotkey_keys = html_options.delete(:hotkey)
        html_options[:data] = (html_options[:data] || {}).merge(hotkey(*Array(hotkey_keys)))
      end

      html_options
    end

    def mac?
      request.user_agent.to_s.include?("Mac")
    end
  end
end
```

### `lib/generators/hotkeys_rails/install_generator.rb`

```ruby
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
```

### `lib/generators/hotkeys_rails/templates/hotkey_controller.js`

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  click(event) {
    if (this.#shouldHandle(event)) {
      event.preventDefault()
      this.element.click()
    }
  }

  focus(event) {
    if (this.#shouldHandle(event)) {
      event.preventDefault()
      this.element.focus()
    }
  }

  #shouldHandle(event) {
    return !event.defaultPrevented &&
           !event.target.closest("input, textarea, [contenteditable]")
  }
}
```

### `lib/generators/hotkeys_rails/templates/hotkey.css`

```css
kbd {
  border: 1px solid currentColor;
  border-radius: 0.3em;
  box-shadow: 0 0.1em 0 currentColor;
  font-family: ui-monospace, monospace;
  font-size: 0.8em;
  font-weight: 600;
  opacity: 0.7;
  padding: 0 0.4em;
}

@media (any-hover: none) {
  .hide-on-touch {
    display: none;
  }
}
```

### `Gemfile`

```ruby
source "https://rubygems.org"

gemspec

gem "rake"
gem "minitest"
```

### `Rakefile`

```ruby
require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

task default: :test
```

## File Checklist

- [ ] `hotkeys-rails.gemspec`
- [ ] `Gemfile`
- [ ] `Rakefile`
- [ ] `lib/hotkeys_rails.rb`
- [ ] `lib/hotkeys_rails/version.rb`
- [ ] `lib/hotkeys_rails/engine.rb`
- [ ] `lib/hotkeys_rails/helper.rb`
- [ ] `lib/generators/hotkeys_rails/install_generator.rb`
- [ ] `lib/generators/hotkeys_rails/templates/hotkey_controller.js`
- [ ] `lib/generators/hotkeys_rails/templates/hotkey.css`

## Key Features

1. **`hotkey: :key`** - Works directly on `link_to`, `button_to`, `button_tag`
2. **Dual ctrl/meta binding** - `:ctrl` binds both Ctrl AND Cmd
3. **`hotkey_label`** - Platform-aware (⌘ on Mac, Ctrl+ elsewhere)
4. **`hotkey_hint`** - Renders `<kbd>` with hide-on-touch
5. **Merges with existing data** - Works alongside turbo_frame, confirm, etc.

## References

- Spec: https://github.com/kieranklaassen/readme-riffing/blob/main/hotkey-rails.md
- Rails Engine Guide: https://guides.rubyonrails.org/engines.html
- Andrew Kane gem patterns: searchkick, strong_migrations, lockbox
