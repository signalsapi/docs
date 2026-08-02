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
    rel = relative(file)
    return true if rel.start_with?(*CONTENT_EXCLUDED_DIRS.map { |d| "#{d}/" })

    config_excludes.include?(rel)
  end

  # _config.yml's own exclude: list also names individual root files (e.g.
  # DESIGN.md) that Jekyll won't publish, so they shouldn't be "pages" here
  # either — a page with no corresponding html_file isn't a page.
  def config_excludes
    @config_excludes ||= YAML.safe_load(File.read(File.join(ROOT, "_config.yml")))["exclude"] || []
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

    def run(site, assertions: registry)
      failures = []
      assertions.each do |assertion|
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

# AD-6: each assertion declares what it covers, so the manifest — and the
# gap report built from it — can contradict a story that claims coverage it
# doesn't have.
module ChecksManifest
  PATH = File.join(ROOT, "_data", "checks.yml")

  def self.live_entries
    Check.registry.sort_by(&:id).map { |a| { "id" => a.id, "desc" => a.desc, "covers" => a.covers } }
  end

  def self.current?
    File.exist?(PATH) && YAML.safe_load(File.read(PATH)) == live_entries
  end

  def self.write!
    require "fileutils"
    FileUtils.mkdir_p(File.dirname(PATH))
    File.write(PATH, YAML.dump(live_entries))
    puts "_data/checks.yml regenerated (#{live_entries.size} assertions)"
  end

  # Story and requirement IDs live in .ralph/, which is this checkout's own
  # gitignored planning workspace, not a repo deliverable — so this report
  # only works from inside it and says so plainly when it isn't present.
  def self.report_uncovered
    fix_plan = File.join(ROOT, ".ralph", "@fix_plan.md")
    prd = File.join(ROOT, ".ralph", "specs", "planning-artifacts", "prd.md")
    context = File.join(ROOT, ".ralph", "PROJECT_CONTEXT.md")

    unless File.exist?(fix_plan) && File.exist?(prd) && File.exist?(context)
      puts "check:coverage: .ralph/ planning artifacts aren't present in this checkout — nothing to compare against"
      return
    end

    story_ids = File.read(fix_plan).scan(/Story (\d+\.\d+)/).flatten.uniq
    fr_ids = File.read(prd).scan(/^-\s+\*\*FR(\d+)\.\*\*/).flatten.map { |n| "FR#{n}" }
    nfr_ids = File.read(context).scan(/^-\s+\*\*NFR(\d+)/).flatten.map { |n| "NFR#{n}" }

    covered = Check.registry.flat_map(&:covers).to_a
    uncovered = (story_ids + fr_ids + nfr_ids) - covered

    if uncovered.empty?
      puts "check:coverage: every story and requirement ID is covered by an assertion"
    else
      puts "check:coverage: #{uncovered.size} uncovered id#{uncovered.size == 1 ? '' : 's'}:"
      uncovered.each { |id| puts "  - #{id}" }
    end
  end
end

Dir.glob(File.join(ROOT, "script", "checks", "*.rb")).sort.each { |f| require f }

case ARGV[0]
when "manifest"
  ChecksManifest.write!
when "coverage"
  ChecksManifest.report_uncovered
else
  target_id = ARGV[0]
  assertions = Check.registry

  if target_id
    assertions = Check.registry.select { |a| a.id == target_id }
    abort("script/check.rb: no assertion registered with id #{target_id.inspect}") if assertions.empty?
  end

  site = Site.new
  failures = Check.run(site, assertions: assertions)

  count = assertions.size
  puts "script/check.rb: #{count} assertion#{count == 1 ? '' : 's'} registered"

  if failures.empty?
    puts "script/check.rb: all assertions passed"
  else
    warn "script/check.rb: #{failures.size} assertion#{failures.size == 1 ? '' : 's'} failed"
    failures.each { |f| warn "  - #{f}" }
    exit 1
  end
end
