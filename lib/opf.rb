# frozen_string_literal: true

require_relative "opf/version"
require_relative "opf/page"
require_relative "opf/fetcher"
require_relative "opf/parser"

# Fetches OpenGraph metadata (title, description, images) and the favicon
# from user-provided URLs.
module Opf
  class Error < StandardError; end

  # Raised when the provided URL cannot be used (missing host, non
  # http/https scheme, malformed URI, ...).
  class InvalidURLError < Error; end

  # Raised when the URL could not be fetched: network failure, too many
  # redirects, unsuccessful status code or a non HTML response.
  class FetchError < Error; end

  # Fetches OpenGraph information for the given URL and returns an Opf::Page.
  #
  #   page = Opf.fetch("https://example.com")
  #   page.title    #=> "Example Domain"
  #   page.image    #=> "https://example.com/og.png"
  #
  # Raises Opf::InvalidURLError or Opf::FetchError on failure.
  def self.fetch(url)
    response = Fetcher.call(url)
    Parser.call(url: response.url, body: response.body)
  end
end
