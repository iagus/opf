# Opf

Opf fetches OpenGraph metadata — title, description and images — plus the site favicon, from user-provided URLs.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add opf
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install opf
```

## Usage

```ruby
require "opf"

page = Opf.fetch("https://ogp.me")

page.title       # => og:title (falls back to the HTML <title>)
page.description # => og:description (falls back to <meta name="description">)
page.images      # => every declared og:image URL
page.image       # => the primary image (first og:image)
page.favicon     # => the site's favicon URL
page.url         # => final URL after following redirects
```

`Opf.fetch` raises typed errors on failure:

- `Opf::InvalidURLError` — malformed URLs or non http/https schemes
- `Opf::FetchError` — network failures, redirect loops, error statuses or non HTML responses

Pages lacking OpenGraph tags simply return `nil`/`[]` for the missing fields.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
