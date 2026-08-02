# frozen_string_literal: true

# Story 6.7: every 4xx status code documented in the REST reference pages
# must be covered on troubleshooting/api-auth.md. This stands in for "the
# statuses reference" named in the story's AC until Story 6.9 builds that
# dedicated page — re-point REFERENCE_PAGES/the target page there once it
# exists.
REFERENCE_PAGES = %w[features/api-access.md features/agent-data-plane-api.md].freeze

Check.register(
  id: "status-codes-cross-referenced",
  desc: "Every 4xx status code documented in the REST reference pages is covered by troubleshooting/api-auth.md",
  covers: ["6.7"]
) do |site|
  codes = REFERENCE_PAGES.flat_map { |path| site.raw(path).scan(/`(4\d{2})`/) }.flatten.uniq

  page = site.pages.find { |p| p.path == "troubleshooting/api-auth.md" }
  site.fail!("troubleshooting/api-auth.md is missing") unless page

  missing = codes.reject { |code| page.body.include?(code) }
  unless missing.empty?
    site.fail!("status code(s) undocumented on troubleshooting/api-auth.md — #{missing.join(', ')}")
  end
end
