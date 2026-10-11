# frozen_string_literal: true

require "net/http"
require "openssl"
require "uri"

module Opf
  # Fetches an HTML document over HTTP(S), following redirects.
  #
  # Only `text/html` documents are accepted. All failure modes raise
  # Opf::InvalidURLError or Opf::FetchError.
  class Fetcher
    MAX_REDIRECTS = 5
    OPEN_TIMEOUT = 5
    READ_TIMEOUT = 5
    USER_AGENT = "Opf/#{Opf::VERSION}".freeze
    HTML_MIME_TYPES = %w[text/html application/xhtml+xml].freeze

    NETWORK_ERRORS = [
      SocketError, # DNS failures
      SystemCallError, # Errno::ECONNREFUSED and friends
      Timeout::Error, # Net::OpenTimeout / Net::ReadTimeout
      OpenSSL::SSL::SSLError, # TLS negotiation failures
      EOFError, # connection dropped mid response
      Net::ProtocolError # malformed HTTP responses
    ].freeze

    # The result of a successful fetch: the final URL (after redirects) and
    # the raw HTML body.
    Response = Data.define(:url, :body)

    def self.call(url)
      new.call(url)
    end

    def call(url)
      uri = parse_uri(url)
      redirects = 0

      loop do
        response = request(uri)
        return success_response(uri, response) if response.is_a?(Net::HTTPSuccess)

        uri = follow_redirect(uri, response, redirects += 1)
      end
    end

    private

    def parse_uri(url)
      uri = URI.parse(url.to_s)
      return uri if http_uri?(uri)

      raise InvalidURLError, "only http(s) URLs are supported: #{url.inspect}"
    rescue URI::InvalidURIError => e
      raise InvalidURLError, "invalid URL #{url.inspect}: #{e.message}"
    end

    def http_uri?(uri)
      uri.is_a?(URI::HTTP) && !uri.host.to_s.empty?
    end

    def request(uri)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                                          open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT) do |http|
        http.request_get(uri.request_uri, "User-Agent" => USER_AGENT, "Accept" => HTML_MIME_TYPES.join(", "))
      end
    rescue *NETWORK_ERRORS => e
      raise FetchError, "request to #{uri} failed: #{e.message}"
    end

    def follow_redirect(uri, response, count)
      raise FetchError, "giving up after #{MAX_REDIRECTS} redirects" if count > MAX_REDIRECTS

      unless response.is_a?(Net::HTTPRedirection)
        raise FetchError, "request to #{uri} failed with status #{response.code}"
      end

      redirect_uri(uri, response)
    end

    def redirect_uri(uri, response)
      location = response["location"].to_s
      raise FetchError, "redirect from #{uri} lacked a Location header" if location.empty?

      redirected = URI.join(uri, location)
      return redirected if http_uri?(redirected)

      raise FetchError, "redirect from #{uri} points to an invalid URL: #{location.inspect}"
    rescue URI::InvalidURIError => e
      raise FetchError, "redirect from #{uri} points to an invalid URL: #{e.message}"
    end

    def success_response(uri, response)
      mime_type = response["content-type"].to_s.split(";").first.to_s.strip
      return Response.new(url: uri.to_s, body: response.body.to_s) if HTML_MIME_TYPES.include?(mime_type)

      raise FetchError,
            "expected an HTML document from #{uri}, got: #{mime_type.empty? ? "no Content-Type" : mime_type}"
    end
  end
end
