# frozen_string_literal: true

require "test_helper"

class TestOpf < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Opf::VERSION
  end

  def test_fetch_returns_a_page
    stub_request(:get, "https://example.com/")
      .to_return(status: 200, body: read_fixture("full_og.html"), headers: { "Content-Type" => "text/html" })

    page = Opf.fetch("https://example.com")

    assert_instance_of Opf::Page, page
    assert_equal "Example OG title", page.title
    assert_equal "An example description", page.description
    assert_equal ["https://example.com/og-1.png", "https://example.com/og-2.png"], page.images
    assert_equal "https://example.com/og-1.png", page.image
    assert_equal "https://example.com/icon.png", page.favicon
  end

  def test_fetch_propagates_fetch_errors
    stub_request(:get, "https://example.com/").to_return(status: 503)

    assert_raises(Opf::FetchError) { Opf.fetch("https://example.com") }
  end
end
