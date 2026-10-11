# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "opf"

require "minitest/autorun"
require "webmock/minitest"

module Minitest
  class Test
    def fixture_path(name)
      File.expand_path(File.join("fixtures", name), __dir__)
    end

    def read_fixture(name)
      File.read(fixture_path(name))
    end
  end
end
