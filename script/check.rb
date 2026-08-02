#!/usr/bin/env ruby
# frozen_string_literal: true

# Runner skeleton (AD-3, AD-4): loads every script/checks/*.rb file, which
# self-register assertions via Check.register, then runs each assertion once
# against a single Site instance and aggregates the failures.

require "yaml"

ROOT = File.expand_path("..", __dir__)

class CheckFailure < StandardError; end

# Site model (AD-4): parsed once per run and handed to every assertion, so
# twenty assertions don't each re-walk _site/ and re-parse front matter.
# Exposes exactly four accessors; a check that needs something else adds one
# here rather than reading the filesystem directly.
class Site
  Page = Struct.new(:path, :front_matter, :body, keyword_init: true)
  HtmlFile = Struct.new(:path, :body, keyword_init: true)

  # Directories that hold no publishable page content: build output, drafts
  # (NFR10), and the planning/tooling scaffolds this repo happens to carry.
  CONTENT_EXCLUDED_DIRS = %w[_site _drafts .claude .github .ralph .jekyll-cache _bmad _bmad-output bmalph].freeze

  def pages
    @pages ||= Dir.glob(File.join(ROOT, "**", "*.md"))
                   .reject { |f| excluded?(f) }
                   .filter_map { |f| parse_page(f) }
                   .sort_by(&:path)
  end

  def html_files
    @html_files ||= Dir.glob(File.join(ROOT, "_site", "**", "*.html")).sort.map do |f|
      HtmlFile.new(path: relative(f), body: File.read(f))
    end
  end

  def data
    @data ||= begin
      data_dir = File.join(ROOT, "_data")
      if Dir.exist?(data_dir)
        Dir.glob(File.join(data_dir, "*.{yml,yaml}")).each_with_object({}) do |f, h|
          h[File.basename(f, ".*")] = YAML.safe_load(File.read(f))
        end
      else
        {}
      end
    end
  end

  def raw(path)
    File.read(File.join(ROOT, path))
  end

  def fail!(message)
    raise CheckFailure, message
  end

  private

  def excluded?(file)
    relative(file).start_with?(*CONTENT_EXCLUDED_DIRS.map { |d| "#{d}/" })
  end

  def relative(file)
    file.sub("#{ROOT}/", "")
  end

  def parse_page(file)
    content = File.read(file)
    return nil unless content.start_with?("---")

    _, front_matter_text, body = content.split(/^---\s*$/, 3)
    Page.new(path: relative(file), front_matter: YAML.safe_load(front_matter_text) || {}, body: body.to_s.strip)
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
