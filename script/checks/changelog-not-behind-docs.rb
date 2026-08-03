# frozen_string_literal: true

require "date"

# Story 11.9 backfilled the two 2026 launches (API access, the agent data
# plane) that had a documentation page and no changelog entry — this is the
# regression guard against the changelog quietly falling behind again.
#
# Scope is deliberately narrow: only page_type: feature pages created at or
# before commit ddc51a8 (2026-07-09) — "the last real-content commit before
# this overhaul began" per _data/baseline.yml. Pages this overhaul itself
# created (concepts/, troubleshooting/, trust.md, apis/index.md, and even
# feature-tagged docs-tooling pages like the fixture gallery) are this
# workstream's own scaffolding, not product launches a changelog documents.
Check.register(
  id: "changelog-not-behind-docs",
  desc: "no pre-overhaul feature page is newer than the newest changelog entry and unnamed by one",
  covers: ["11.9"]
) do |site|
  items = site.data.dig("changelog", "items") || []
  site.fail!("_data/changelog.yml has no items") if items.empty?

  newest_entry_date = items.map { |i| i["date"] }.max
  named_pages = items.map { |i| i["feature"] }.to_set
  overhaul_cutoff = Date.new(2026, 7, 9)

  candidates = site.pages
                   .reject { |p| named_pages.include?(p.path) }
                   .select { |p| p.front_matter["page_type"] == "feature" }

  offenders = candidates.select do |page|
    log = `git -C #{ROOT} log --follow --format=%ad --date=short -- #{page.path}`.strip
    next false if log.empty?

    created_on = Date.parse(log.lines.last.strip)
    created_on <= overhaul_cutoff && created_on > newest_entry_date
  end

  unless offenders.empty?
    site.fail!("feature page(s) predating this overhaul have no changelog entry — #{offenders.map(&:path).join(', ')}")
  end
end
