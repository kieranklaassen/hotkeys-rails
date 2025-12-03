# Changelog

All notable changes to this project will be documented in this file.

## [0.1.1] - 2024-12-03

### Fixed

- Bundler auto-loading now works without explicit `require: "hotkeys_rails"` in Gemfile ([#1](https://github.com/kieranklaassen/hotkeys-rails/issues/1))

## [0.1.0] - 2024-12-02

Initial release.

### Added

- `hotkey` option for `link_to`, `button_to`, and `button_tag` helpers
- `hotkey(*keys)` helper for explicit data attribute generation
- `hotkey_label(*keys)` for platform-aware keyboard shortcut labels
- `hotkey_hint(*keys)` for rendering `<kbd>` elements
- Dual binding for `:ctrl` modifier (Ctrl on Windows/Linux, Cmd on Mac)
- Focus action support via `hotkey(:key, action: :focus)`
- Rails generator for installing Stimulus controller
- Demo app for testing with Playwright
