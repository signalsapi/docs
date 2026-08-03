# frozen_string_literal: true

# Story 6.9 built the dedicated statuses reference this assertion targets.
REFERENCE_PAGES = %w[features/api-access.md features/agent-data-plane-api.md].freeze

Check.register(
  id: "status-codes-cross-referenced",
  desc: "Every 4xx status code documented in the REST reference pages is covered by the statuses reference",
  covers: %w[6.7 6.9]
) do |site|
  codes = REFERENCE_PAGES.flat_map { |path| site.raw(path).scan(/`(4\d{2})`/) }.flatten.uniq

  page = site.pages.find { |p| p.path == "troubleshooting/statuses.md" }
  site.fail!("troubleshooting/statuses.md is missing") unless page

  missing = codes.reject { |code| page.body.include?(code) }
  unless missing.empty?
    site.fail!("status code(s) undocumented on troubleshooting/statuses.md — #{missing.join(', ')}")
  end
end
