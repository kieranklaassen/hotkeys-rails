# Hotkeys Rails

Keyboard shortcuts for Hotwire apps. No dependencies. No configuration. Just HTML.

## Installation

Add to your Gemfile:

```ruby
gem "hotkeys-rails"
```

Run:

```sh
bundle install
rails generate hotkeys_rails:install
```

## Usage

```erb
<%= link_to "Back", root_path, hotkey: :esc %>
<%= button_to "New Card", cards_path, hotkey: :c %>
<%= button_tag "Save", hotkey: [:ctrl, :enter] %>
```

The `:ctrl` modifier binds both Ctrl (Windows/Linux) and Cmd (Mac).

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

## Helpers

- `hotkey(*keys)` - Returns data attributes for Stimulus controller
- `hotkey_label(*keys)` - Platform-aware label (⌘ on Mac, Ctrl+ elsewhere)
- `hotkey_hint(*keys)` - Renders `<kbd>` element with hide-on-touch class

## License

MIT
