#!/usr/bin/env ruby
# frozen_string_literal: true

# Runner skeleton (AD-3, AD-4): loads every script/checks/*.rb file, which
# self-register assertions via Check.register, then runs each assertion once
# against a single Site instance and aggregates the failures.

require "yaml"
require "date"

ROOT = File.expand_path("..", __dir__)

class CheckFailure < StandardError; end

# Site model (AD-4): parsed once per run and handed to every assertion, so
# twenty assertions don't each re-walk _site/ and re-parse front matter.
# Exposes exactly nine accessors; a check that needs something else adds one
# here rather than reading the filesystem directly.
#
# Every accessor also tallies what it handed the running assertion, which is
# what makes `passed` distinguishable from `had nothing to look at` (see
# Check.run). That tally only works if the assertion asks the model for its
# subjects — an assertion that reaches past it to File./Dir. reports nothing
# examined and the runner fails it, which is the enforcement the design rule
# above never had.
class Site
  Page = Struct.new(:path, :front_matter, :body, keyword_init: true)
  HtmlFile = Struct.new(:path, :body, keyword_init: true)

  # Directories that hold no publishable page content: build output, drafts
  # (NFR10), the planning/tooling scaffolds this repo happens to carry, and
  # third-party dependency trees. `vendor/` and `node_modules/` are absent on a
  # developer machine but present in CI, where `bundler-cache: true` installs
  # gems into `vendor/bundle/` inside the checkout — jekyll ignores them via its
  # own default excludes, and every assertion here has to ignore them too, or a
  # gem's spec fixtures get audited as if they were our pages.
  CONTENT_EXCLUDED_DIRS = %w[
    _site _drafts .claude .github .ralph .jekyll-cache _bmad _bmad-output bmalph vendor node_modules
  ].freeze

  def pages
    @pages ||= Dir.glob(File.join(ROOT, "**", "*.md"))
                   .reject { |f| excluded?(f) }
                   .filter_map { |f| parse_page(f) }
                   .sort_by(&:path)
    note("pages", @pages.size)
    @pages
  end

  # jekyll-redirect-from's stub pages (Story 8.8) are real built HTML, but
  # they're a bare "Redirecting..." shell, not a rendered content page —
  # every assertion that checks a page's own structure (footer, og:image,
  # canonical) means the real page, not the redirect standing in for its
  # old URL.
  def html_files
    @html_files ||= Dir.glob(File.join(ROOT, "_site", "**", "*.html"))
                        .reject { |f| redirect_stub?(f) }
                        .sort.map do |f|
      HtmlFile.new(path: relative(f), body: File.read(f))
    end
    note("built pages", @html_files.size)
    @html_files
  end

  # A built page narrowed to its own content, with the chrome every page
  # carries stripped off. just-the-docs renders the nav, the search box, the
  # breadcrumbs and the footer into all of them, so an assertion that searches
  # a whole built body asks "does the SITE say this?" when it means "does this
  # PAGE say it?" — and anything the theme emits then satisfies it everywhere
  # at once, whatever the page itself says.
  #
  # That is not hypothetical. affiliate-disclosure-linked could not fail at all,
  # because the nav links to /how-we-make-money/ from all 58 pages
  # (signalsapi-4324); no-instruction-only-in-image accepted a control name
  # documented only inside a built <img alt> (signalsapi-4327). Neither vacuity
  # instrument sees this class — the subject set is non-empty and the pages
  # really are read, so only the predicate is degenerate — which is why the
  # region lives here, where the next assertion inherits it, rather than in
  # whichever check happened to need it last.
  CONTENT_REGION_RE = %r{<main\b[^>]*>(.*?)</main>}m.freeze

  def content_pages
    @content_pages ||= html_files.map do |file|
      region = file.body[CONTENT_REGION_RE, 1]
      if region.nil?
        fail!("#{file.path} renders no <main> element, so no assertion can tell what the page " \
              "itself says from the chrome every page carries")
      end
      HtmlFile.new(path: file.path, body: region)
    end
    note("built page content regions", @content_pages.size)
    @content_pages
  end

  def data
    @data ||= begin
      data_dir = File.join(ROOT, "_data")
      if Dir.exist?(data_dir)
        Dir.glob(File.join(data_dir, "*.{yml,yaml}")).each_with_object({}) do |f, h|
          h[File.basename(f, ".*")] = YAML.safe_load(File.read(f), permitted_classes: [Date])
        end
      else
        {}
      end
    end
    note("data files", @data.size)
    @data
  end

  def raw(path)
    note_path(path)
    File.read(File.join(ROOT, path))
  end

  # The three accessors below exist because twenty-three assertions were
  # reaching past this model to File./Dir. for exactly these three things —
  # does a path exist, is it a directory, what matches this glob. Reading the
  # repository through the model is what lets the runner see that they read
  # anything at all.
  def exist?(path)
    note_path(path)
    File.exist?(File.join(ROOT, path))
  end

  def dir?(path)
    note_path(path)
    File.directory?(File.join(ROOT, path))
  end

  # Files only: every caller wants files, and a bare Dir.glob also returns the
  # directories along the way, which no assertion has ever meant to audit.
  def glob(pattern)
    matches = Dir.glob(File.join(ROOT, pattern)).select { |f| File.file?(f) }.map { |f| relative(f) }.sort
    note("#{pattern} matches", matches.size)
    matches
  end

  # GitHub Actions runs a workflow saved with either extension, so the subject
  # set meant by "every workflow" is both. A single-extension glob silently
  # exempts `probe.yaml` from whatever rule an assertion means to apply to all
  # of them, and nothing about that filename looks wrong to the contributor who
  # writes it (signalsapi-4306). The vacuity instrument above cannot catch it:
  # the narrow glob still examines the files it does match, so the count is
  # non-zero and the assertion passes for a reason unrelated to what it claims.
  #
  # Which extensions count is a fact about GitHub, not about any one assertion,
  # so it is recorded here once. That is what stops the next workflow-reading
  # assertion from copying the narrow glob out of the last one.
  def workflows
    glob(".github/workflows/*.{yml,yaml}")
  end

  # Declares the subject set an assertion actually asserts over, when that is
  # narrower than — or simply not — what the accessors above hand out. Returns
  # its argument so it reads inline, and fails on an empty set: an assertion
  # with nothing to check is not passing, it is silent. This is the generalised
  # form of the vacuity guards several assertions had to hand-roll one at a
  # time (see idempotency-key-on-metered-operations for the long-hand version).
  def examining(what, subjects)
    count = if subjects.respond_to?(:size)
              subjects.size
            else
              subjects.nil? ? 0 : 1
            end
    note(what, count)
    fail!("examined no #{what}, so there was nothing for this assertion to find") if count.zero?

    subjects
  end

  def fail!(message)
    raise CheckFailure, message
  end

  # --- vacuity instrumentation (Check.run drives these) ---

  def begin_assertion
    @examined = {}
    @examined_paths = []
  end

  # Repeated reads of one path, and repeated calls to one accessor, are one
  # subject each — a count that grew every time an assertion looked twice
  # would measure effort rather than coverage.
  def examined
    tally = (@examined ||= {}).dup
    paths = (@examined_paths ||= []).uniq
    tally["files"] = paths.size unless paths.empty?
    tally
  end

  def examined_count
    examined.values.sum
  end

  private

  def note(what, count)
    (@examined ||= {})[what] = count
  end

  def note_path(path)
    (@examined_paths ||= []) << path
  end

  def excluded?(file)
    rel = relative(file)
    return true if rel.start_with?(*CONTENT_EXCLUDED_DIRS.map { |d| "#{d}/" })

    config_excludes.include?(rel)
  end

  def redirect_stub?(file)
    File.read(file).include?('<meta http-equiv="refresh"')
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
    front_matter = YAML.safe_load(front_matter_text, permitted_classes: [Date]) || {}
    Page.new(path: relative(file), front_matter: front_matter, body: body.to_s.strip)
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

    # What each assertion examined on the last run, keyed by id — the data
    # behind `ruby script/check.rb examined`.
    def examined
      @examined ||= {}
    end

    def run(site, assertions: registry)
      failures = []
      @examined = {}

      assertions.each do |assertion|
        site.begin_assertion
        begin
          assertion.block.call(site)
          failures << vacuity_failure(assertion) if site.examined_count.zero?
        rescue CheckFailure => e
          failures << "#{assertion.id}: #{e.message}"
        ensure
          @examined[assertion.id] = site.examined
        end
      end

      failures
    end

    private

    # A green assertion that consulted nothing is not evidence of anything: it
    # would have passed just as happily against an empty repository, so it
    # cannot fail the day the thing it guards breaks. Reported as a failure
    # rather than a warning because a warning is what the run already had —
    # nothing — and the whole point is that this is visible every run rather
    # than the once someone thinks to look.
    def vacuity_failure(assertion)
      "#{assertion.id}: passed without examining anything. It consulted no page, built file, data " \
        "file or repository file through the Site model, so nothing it could read would make it " \
        "fail. Read its subjects through site (pages/html_files/data/raw/exist?/dir?/glob), or " \
        "declare them with site.examining(what, subjects)."
    end
  end
end

# AD-6: each assertion declares what it covers, so the manifest — and the
# gap report built from it — can contradict a story that claims coverage it
# doesn't have.
module ChecksManifest
  PATH = File.join(ROOT, "_data", "checks.yml")
  OWNER = "mykola"
  SOURCE = "generated by `rake check:manifest` from the live Check registry"

  def self.live_items
    Check.registry.sort_by(&:id).map { |a| { "id" => a.id, "desc" => a.desc, "covers" => a.covers } }
  end

  # AD-7's envelope convention (Story 7.1): meta/items is all the shape a
  # data file has, so staleness is judged on items: alone — meta.verified_on
  # is just "whenever this was last regenerated," not a live-registry fact.
  def self.current?
    return false unless File.exist?(PATH)

    data = YAML.safe_load(File.read(PATH), permitted_classes: [Date])
    data.is_a?(Hash) && data["items"] == live_items
  end

  def self.write!
    require "fileutils"
    items = live_items
    envelope = { "meta" => { "owner" => OWNER, "verified_on" => Date.today, "source" => SOURCE }, "items" => items }
    FileUtils.mkdir_p(File.dirname(PATH))
    File.write(PATH, YAML.dump(envelope))
    puts "_data/checks.yml regenerated (#{items.size} assertions)"
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
when "examined"
  # Answers "which of these assertions is cost without coverage?" from inside
  # the harness — the question signalsapi-4286 could only approach from the
  # outside, by emptying a Site and seeing what still passed.
  Check.run(Site.new)
  Check.registry.sort_by(&:id).each do |assertion|
    breakdown = Check.examined[assertion.id] || {}
    detail = breakdown.map { |what, count| "#{what}=#{count}" }.join(" ")
    puts format("%-48s %5d examined  %s", assertion.id, breakdown.values.sum, detail)
  end
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
