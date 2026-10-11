# frozen_string_literal: true

require "nokogiri"
require "uri"

module Opf
  # Extracts metadata from a fetched HTML document: OpenGraph tags with plain
  # HTML fallbacks, plus the site's favicon.
  class Parser
    IMAGE_PROPERTIES = %w[og:image og:image:secure_url og:image:url].freeze

    def self.call(url:, body:)
      new(url: url, body: body).call
    end

    def initialize(url:, body:)
      @url = url
      @body = body
    end

    def call
      Page.new(
        url: @url,
        title: open_graph("og:title") || html_title,
        description: open_graph("og:description") || html_description,
        images: images,
        favicon: favicon
      )
    end

    private

    def doc
      @doc ||= Nokogiri::HTML(@body)
    end

    # Some sites wrongly use a `name` attribute for OpenGraph tags, so both
    # spellings are accepted.
    def open_graph(property)
      tag = doc.at_css(%(meta[property="#{property}"]), %(meta[name="#{property}"]))
      content = tag&.[]("content").to_s.strip
      content.empty? ? nil : content
    end

    def html_title
      title = doc.at_css("title")&.text.to_s.strip
      title.empty? ? nil : title
    end

    def html_description
      tag = doc.at_css('meta[name="description"]')
      content = tag&.[]("content").to_s.strip
      content.empty? ? nil : content
    end

    def images
      doc.css(image_selector).filter_map { |tag| tag["content"] }.map(&:strip).reject(&:empty?).uniq
    end

    def image_selector
      IMAGE_PROPERTIES
        .flat_map { |property| [%(meta[property="#{property}"]), %(meta[name="#{property}"])] }.join(", ")
    end

    # The site's favicon: a declared <link rel="icon">, then the legacy
    # "shortcut icon" spelling, and finally the conventional /favicon.ico,
    # which is returned unverified.
    def favicon
      resolve(declared_favicon || "/favicon.ico")
    end

    def declared_favicon
      links = doc.css("link[href]")
      link = links.find { rel_tokens(_1) == ["icon"] } ||
             links.find { rel_tokens(_1) == %w[icon shortcut] }
      href = link&.[]("href").to_s.strip
      href.empty? || href.start_with?("data:") ? nil : href
    end

    def rel_tokens(link)
      link["rel"].to_s.downcase.split.sort
    end

    # Relative hrefs are common for favicons; they resolve against the final
    # (post-redirect) page URL.
    def resolve(href)
      URI.join(@url, href).to_s
    rescue URI::InvalidURIError
      nil
    end
  end
end
