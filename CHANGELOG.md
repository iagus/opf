## [Unreleased]

### Added

- `Opf.fetch(url)`: fetches a page and returns an `Opf::Page` with `title`, `description`, `images` (plus `image` shortcut) and `favicon`, resolved from OpenGraph tags with HTML fallbacks
- Typed errors: `Opf::InvalidURLError` and `Opf::FetchError`

## [0.1.0] - 2026-10-11

- Initial release
