#!/usr/bin/env ruby
# frozen_string_literal: true

# Runner skeleton (AD-3, AD-4): loads every script/checks/*.rb file, which
# self-register assertions via Check.register, then runs each assertion once
# against a single Site instance and aggregates the failures.

ROOT = File.expand_path("..", __dir__)

class CheckFailure < StandardError; end

# Site model (AD-4). Story 1.7 fills in pages/html_files/data/raw; today it
# exists only so assertion blocks have somewhere to call #fail! on.
class Site
  def fail!(message)
    raise CheckFailure, message
  end
end

module Check
  Assertion = Struct.new(:id, :desc, :covers, :block, :source, keyword_init: true)

  class << self
    def registry
      @registry ||= []
    end

    def register(id:, desc:, covers: [], &block)
      source = caller_locations(1, 1).first.path.sub("#{ROOT}/", "")

      if (existing = registry.find { |a| a.id == id })
        abort("script/check.rb: duplicate assertion id #{id.inspect} registered in both " \
              "#{existing.source} and #{source}")
      end

      registry << Assertion.new(id: id, desc: desc, covers: covers, block: block, source: source)
    end

    def run(site)
      failures = []
      registry.each do |assertion|
        begin
          assertion.block.call(site)
        rescue CheckFailure => e
          failures << "#{assertion.id}: #{e.message}"
        end
      end
      failures
    end
  end
end

Dir.glob(File.join(ROOT, "script", "checks", "*.rb")).sort.each { |f| require f }

site = Site.new
failures = Check.run(site)

count = Check.registry.size
puts "script/check.rb: #{count} assertion#{count == 1 ? '' : 's'} registered"

if failures.empty?
  puts "script/check.rb: all assertions passed"
else
  warn "script/check.rb: #{failures.size} assertion#{failures.size == 1 ? '' : 's'} failed"
  failures.each { |f| warn "  - #{f}" }
  exit 1
end
