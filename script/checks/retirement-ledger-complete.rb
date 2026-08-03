# frozen_string_literal: true

require "cgi"

# Story 11.13: a deleted or renamed page should read as a documented
# decision, not a disappearance. Every redirect_from entry declared
# anywhere in the repository — from Epic 2's permalink migration and
# Epic 11's page retirements alike — must appear on the built
# /retirement-ledger/ page.
Check.register(
  id: "retirement-ledger-complete",
  desc: "every redirect_from entry in the repository appears on the built retirement-ledger page",
  covers: ["11.13"]
) do |site|
  retired_urls = site.pages.flat_map { |p| Array(p.front_matter["redirect_from"]) }
  site.fail!("no page declares redirect_from — nothing for the retirement ledger to cover") if retired_urls.empty?

  ledger = site.html_files.find { |f| f.path == "_site/retirement-ledger/index.html" }
  site.fail!("_site/retirement-ledger/index.html is missing") unless ledger

  missing = retired_urls.uniq.reject { |url| ledger.body.include?(CGI.escapeHTML(url)) || ledger.body.include?(url) }
  site.fail!("retirement ledger is missing redirect_from URL(s): #{missing.join(', ')}") unless missing.empty?
end
