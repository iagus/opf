# frozen_string_literal: true

module Opf
  # Immutable value object with everything we managed to learn about a page:
  # its final URL, title, description, every declared OpenGraph image and the
  # favicon URL.
  Page = Data.define(:url, :title, :description, :images, :favicon) do
    # The primary image: the first og:image declared by the page.
    def image
      images&.first
    end
  end
end
