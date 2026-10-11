# frozen_string_literal: true

require "test_helper"

class TestParser < Minitest::Test
  def parse(fixture, url: "https://example.com/")
    Opf::Parser.call(url: url, body: read_fixture(fixture))
  end

  def test_full_open_graph_page
    page = parse("full_og.html")

    assert_equal "https://example.com/", page.url
    assert_equal "Example OG title", page.title
    assert_equal "An example description", page.description
    assert_equal ["https://example.com/og-1.png", "https://example.com/og-2.png"], page.images
    assert_equal "https://example.com/og-1.png", page.image
    assert_equal "https://example.com/icon.png", page.favicon
  end

  def test_partial_open_graph_falls_back_to_html_description
    page = parse("partial_og.html")

    assert_equal "Just OG Title", page.title
    assert_equal "Plain meta description", page.description
    assert_equal [], page.images
    assert_nil page.image
  end

  def test_page_without_open_graph_uses_plain_html
    page = parse("no_og.html")

    assert_equal "Plain Page Title", page.title
    assert_equal "Plain description.", page.description
    assert_empty page.images
    assert_nil page.image
  end

  def test_shortcut_icon_loses_to_modern_icon
    page = parse("full_og.html")

    assert_equal "https://example.com/icon.png", page.favicon
  end

  def test_relative_favicon_is_resolved_against_final_url
    page = parse("favicon_relative.html", url: "https://blog.example.com/posts/1?utm_source=newsletter")

    assert_equal "https://blog.example.com/assets/icon.svg", page.favicon
  end

  def test_undeclared_icon_falls_back_to_favicon_ico
    page = parse("no_og.html", url: "https://example.com/any/path")

    assert_equal "https://example.com/favicon.ico", page.favicon
  end

  def test_data_uri_icon_is_skipped
    page = parse("favicon_data_uri.html", url: "https://example.com/")

    assert_equal "https://example.com/favicon.ico", page.favicon
  end
end
