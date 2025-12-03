require_relative "test_helper"

class HelperTest < Minitest::Test
  include HotkeysRails::Helper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::CaptureHelper

  attr_accessor :output_buffer

  def setup
    @output_buffer = ActionView::OutputBuffer.new
    @user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
  end

  def request
    Struct.new(:user_agent).new(@user_agent)
  end

  def set_user_agent(ua)
    @user_agent = ua
  end

  # hotkey tests
  def test_hotkey_single_key
    result = hotkey(:esc)
    assert_equal "hotkey", result[:controller]
    assert_equal "keydown.esc@document->hotkey#click", result[:action]
  end

  def test_hotkey_single_key_string
    result = hotkey("k")
    assert_equal "hotkey", result[:controller]
    assert_equal "keydown.k@document->hotkey#click", result[:action]
  end

  def test_hotkey_modifier_combo
    result = hotkey(:shift, :g)
    assert_equal "keydown.shift+g@document->hotkey#click", result[:action]
  end

  def test_hotkey_ctrl_binds_both_ctrl_and_meta
    result = hotkey(:ctrl, :enter)
    assert_includes result[:action], "keydown.ctrl+enter@document->hotkey#click"
    assert_includes result[:action], "keydown.meta+enter@document->hotkey#click"
  end

  def test_hotkey_focus_action
    result = hotkey(:f, action: :focus)
    assert_equal "keydown.f@document->hotkey#focus", result[:action]
  end

  def test_hotkey_array_input
    result = hotkey([:ctrl, :s])
    assert_includes result[:action], "keydown.ctrl+s@document->hotkey#click"
    assert_includes result[:action], "keydown.meta+s@document->hotkey#click"
  end

  # hotkey_label tests - Mac
  def test_hotkey_label_single_key_mac
    assert_equal "K", hotkey_label(:k)
  end

  def test_hotkey_label_ctrl_mac
    assert_equal "⌘", hotkey_label(:ctrl)
  end

  def test_hotkey_label_ctrl_enter_mac
    assert_equal "⌘Return", hotkey_label(:ctrl, :enter)
  end

  def test_hotkey_label_shift_mac
    assert_equal "⇧G", hotkey_label(:shift, :g)
  end

  def test_hotkey_label_alt_mac
    assert_equal "⌥", hotkey_label(:alt)
  end

  def test_hotkey_label_esc
    assert_equal "Esc", hotkey_label(:esc)
  end

  def test_hotkey_label_meta_mac
    assert_equal "⌘", hotkey_label(:meta)
  end

  # hotkey_label tests - Windows/Linux
  def test_hotkey_label_ctrl_windows
    set_user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    assert_equal "Ctrl+", hotkey_label(:ctrl)
  end

  def test_hotkey_label_ctrl_enter_windows
    set_user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    assert_equal "Ctrl+Enter", hotkey_label(:ctrl, :enter)
  end

  def test_hotkey_label_shift_windows
    set_user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    assert_equal "Shift+G", hotkey_label(:shift, :g)
  end

  def test_hotkey_label_enter_mac
    assert_equal "Return", hotkey_label(:enter)
  end

  def test_hotkey_label_enter_windows
    set_user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    assert_equal "Enter", hotkey_label(:enter)
  end

  # hotkey_hint tests
  def test_hotkey_hint_renders_kbd
    result = hotkey_hint(:c)
    assert_match(/<kbd[^>]*>C<\/kbd>/, result)
    assert_match(/class="hide-on-touch"/, result)
  end

  def test_hotkey_hint_with_modifiers
    result = hotkey_hint(:ctrl, :s)
    assert_match(/<kbd[^>]*>⌘S<\/kbd>/, result)
  end

  # extract_hotkey_option tests
  def test_extract_hotkey_option_nil
    result = send(:extract_hotkey_option, nil)
    assert_equal({}, result)
  end

  def test_extract_hotkey_option_with_hotkey
    result = send(:extract_hotkey_option, { hotkey: :esc, class: "btn" })
    assert_equal "btn", result[:class]
    assert_equal "hotkey", result[:data][:controller]
    assert_nil result[:hotkey]
  end

  def test_extract_hotkey_option_merges_with_existing_data
    result = send(:extract_hotkey_option, { hotkey: :esc, data: { turbo_frame: "modal" } })
    assert_equal "modal", result[:data][:turbo_frame]
    assert_equal "hotkey", result[:data][:controller]
  end

  def test_extract_hotkey_option_does_not_mutate_original
    original = { hotkey: :esc, class: "btn" }
    send(:extract_hotkey_option, original)
    assert_equal :esc, original[:hotkey]
  end

  # mac? tests
  def test_mac_detection_true
    assert send(:mac?)
  end

  def test_mac_detection_false
    set_user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    refute send(:mac?)
  end

  def test_mac_detection_nil_user_agent
    set_user_agent(nil)
    refute send(:mac?)
  end

  def test_mac_detection_linux
    set_user_agent("Mozilla/5.0 (X11; Linux x86_64)")
    refute send(:mac?)
  end
end
