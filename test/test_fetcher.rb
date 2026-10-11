# frozen_string_literal: true

require "test_helper"

class TestFetcher < Minitest::Test
  def stub_get(url, **args)
    stub_request(:get, url).to_return(**args)
  end

  def test_returns_body_and_final_url
    stub_get("https://example.com/", status: 200, body: "<html></html>", headers: { "Content-Type" => "text/html" })

    response = Opf::Fetcher.call("https://example.com/")

    assert_equal "https://example.com/", response.url
    assert_equal "<html></html>", response.body
  end

  def test_follows_redirects
    stub_get("http://example.com/", status: 301, headers: { "Location" => "https://www.example.com/landing" })
    stub_get("https://www.example.com/landing", status: 200, body: "<html></html>",
                                                headers: { "Content-Type" => "text/html; charset=utf-8" })

    response = Opf::Fetcher.call("http://example.com/")

    assert_equal "https://www.example.com/landing", response.url
  end

  def test_raises_on_too_many_redirects
    stub_get("https://example.com/loop", status: 302, headers: { "Location" => "https://example.com/loop" })

    error = assert_raises(Opf::FetchError) { Opf::Fetcher.call("https://example.com/loop") }
    assert_match(/redirects/, error.message)
  end

  def test_raises_on_redirect_without_location
    stub_get("https://example.com/", status: 302)

    assert_raises(Opf::FetchError) { Opf::Fetcher.call("https://example.com/") }
  end

  def test_raises_on_redirect_to_non_http_url
    stub_get("https://example.com/", status: 302, headers: { "Location" => "file:///etc/passwd" })

    assert_raises(Opf::FetchError) { Opf::Fetcher.call("https://example.com/") }
  end

  def test_raises_on_error_status
    stub_get("https://example.com/", status: 404)

    error = assert_raises(Opf::FetchError) { Opf::Fetcher.call("https://example.com/") }
    assert_match(/404/, error.message)
  end

  def test_raises_on_non_html_content_type
    stub_get("https://example.com/image.png", status: 200, body: "PNG", headers: { "Content-Type" => "image/png" })

    assert_raises(Opf::FetchError) { Opf::Fetcher.call("https://example.com/image.png") }
  end

  def test_raises_on_network_failure
    stub_request(:get, "https://example.com/").to_timeout

    assert_raises(Opf::FetchError) { Opf::Fetcher.call("https://example.com/") }
  end

  def test_raises_on_unsupported_scheme
    assert_raises(Opf::InvalidURLError) { Opf::Fetcher.call("ftp://example.com/file") }
  end

  def test_raises_on_malformed_url
    assert_raises(Opf::InvalidURLError) { Opf::Fetcher.call(":: not a url ::") }
  end

  def test_raises_on_url_without_host
    assert_raises(Opf::InvalidURLError) { Opf::Fetcher.call("https://") }
  end
end
