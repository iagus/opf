# frozen_string_literal: true

require_relative "lib/opf/version"

Gem::Specification.new do |spec|
  spec.name = "opf"
  spec.version = Opf::VERSION
  spec.authors = ["iagus"]
  spec.email = ["iagus.widget524@passinbox.com"]

  spec.summary = "Fetch OpenGraph metadata (title, description, images) and favicons from URLs."
  spec.description = "Opf fetches OpenGraph metadata (title, description, images) and the favicon URL " \
                     "from user-provided URLs, raising typed errors for invalid URLs or failed fetches."
  spec.homepage = "https://github.com/iagus/opf"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://rubygems.org"
  spec.metadata["changelog_uri"] = "https://rubygems.org"

  # Uncomment the line below to require MFA for gem pushes.
  # This helps protect your gem from supply chain attacks by ensuring
  # no one can publish a new version without multi-factor authentication.
  # See: https://guides.rubygems.org/mfa-requirement-opt-in/
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile test/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies of the gem
  spec.add_dependency "nokogiri", "~> 1.19"

  # For more information and examples about making a new gem, check out our
  # guide at: https://guides.rubygems.org/make-your-own-gem/
end
