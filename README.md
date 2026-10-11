# Opf

Opf fetches OpenGraph metadata — title, description and images — plus the site favicon, from user-provided URLs. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
