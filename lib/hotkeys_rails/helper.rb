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
      # Mac symbols (⌘⌥⇧) don't need + separator, Windows modifiers do (Ctrl+, Alt+, Shift+)
      # gsub removes trailing + from Mac symbols: "⌘+" -> "⌘"
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
      if block_given?
        # link_to(url, html_options) { content }
        html_options = extract_hotkey_option(options)
        super(name, html_options, &block)
      else
        # link_to(name, url, html_options)
        html_options = extract_hotkey_option(html_options)
        super(name, options, html_options)
      end
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
