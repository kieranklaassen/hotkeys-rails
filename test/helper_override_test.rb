require_relative "test_helper"
require "action_view/test_case"

class HelperOverrideTest < ActionView::TestCase
  include HotkeysRails::Helper

  # Mock request for mac? detection
  def request
    @request ||= Struct.new(:user_agent).new("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)")
  end

  # Mock url_for for link_to/button_to
  def url_for(options)
    case options
    when String then options
    when Hash then options[:path] || "/"
    else "/"
    end
  end

  # Mock protect_against_forgery? for button_to
  def protect_against_forgery?
    false
  end

  # link_to tests
  def test_link_to_with_hotkey_option
    result = link_to("Back", "/", hotkey: :esc)
    assert_match(/data-controller="hotkey"/, result)
    # HTML escapes -> to &gt; so check for that
    assert_match(/keydown\.esc@document-/, result)
    assert_match(/hotkey#click/, result)
    assert_match(/href="\/"/,  result)
    assert_match(/>Back</, result)
  end

  def test_link_to_with_modifier_hotkey
    result = link_to("Save", "/save", hotkey: [:ctrl, :s])
    assert_match(/data-controller="hotkey"/, result)
    assert_match(/keydown\.ctrl\+s@document-/, result)
    assert_match(/keydown\.meta\+s@document-/, result)
  end

  def test_link_to_with_block_and_hotkey
    result = link_to("/cards", hotkey: :c) { "Cards" }
    assert_match(/>Cards</, result)
    assert_match(/data-controller="hotkey"/, result)
    assert_match(/keydown\.c@document-/, result)
  end

  def test_link_to_without_hotkey_works_normally
    result = link_to("Home", "/")
    assert_match(/href="\/"/, result)
    assert_match(/>Home</, result)
    refute_match(/data-controller/, result)
  end

  def test_link_to_merges_hotkey_with_existing_data
    result = link_to("Edit", "/edit", hotkey: :e, data: { turbo_frame: "modal" })
    assert_match(/data-turbo-frame="modal"/, result)
    assert_match(/data-controller="hotkey"/, result)
    assert_match(/keydown\.e@document-/, result)
  end

  def test_link_to_preserves_other_html_options
    result = link_to("Back", "/", hotkey: :esc, class: "btn", id: "back-btn")
    assert_match(/class="btn"/, result)
    assert_match(/id="back-btn"/, result)
    assert_match(/data-controller="hotkey"/, result)
  end

  # button_tag tests
  def test_button_tag_with_hotkey_option
    result = button_tag("Save", hotkey: [:ctrl, :enter])
    assert_match(/data-controller="hotkey"/, result)
    assert_match(/keydown\.ctrl\+enter@document-/, result)
    assert_match(/keydown\.meta\+enter@document-/, result)
    assert_match(/>Save</, result)
  end

  def test_button_tag_with_block_and_hotkey
    result = button_tag(hotkey: :s) { "Submit" }
    assert_match(/>Submit</, result)
    assert_match(/data-controller="hotkey"/, result)
  end

  def test_button_tag_without_hotkey_works_normally
    result = button_tag("Click me")
    assert_match(/>Click me</, result)
    refute_match(/data-controller/, result)
  end

  def test_button_tag_with_hotkey_and_other_options
    result = button_tag("Save", hotkey: :s, class: "btn-primary", type: "submit")
    assert_match(/class="btn-primary"/, result)
    assert_match(/type="submit"/, result)
    assert_match(/data-controller="hotkey"/, result)
  end

  # button_to tests
  def test_button_to_with_hotkey_option
    result = button_to("Delete", "/delete", hotkey: [:ctrl, :d])
    assert_match(/data-controller="hotkey"/, result)
    assert_match(/keydown\.ctrl\+d@document-/, result)
  end

  def test_button_to_without_hotkey_works_normally
    result = button_to("Submit", "/submit")
    assert_match(/action="\/submit"/, result)
    refute_match(/data-controller="hotkey"/, result)
  end

  def test_button_to_with_hotkey_and_method
    result = button_to("Delete", "/items/1", hotkey: :d, method: :delete)
    assert_match(/data-controller="hotkey"/, result)
  end
end
