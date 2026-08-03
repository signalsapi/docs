# frozen_string_literal: true

# PRD § Out of Scope item 9 (_bmad-output/planning-artifacts/prd.md): "Analytics,
# telemetry, feedback collectors, zero-result search logging — anything that POSTs",
# because a collector "needs a backend, a retention policy and a privacy disclosure
# this workstream cannot deliver". So this site collects no reader traffic, and the
# keep-or-retire signals it does have are structural: inbound links
# (no-orphan-pages) and verification age (page-staleness), both published on
# /docs-health/.
#
# That exclusion had no assertion behind it, unlike its siblings —
# no-service-worker guards out-of-scope item 16, no-live-sandbox-claim item 2 — so
# one pasted snippet in _includes/head_custom.html would have reversed a product
# decision with a green build.
#
# It bans LOADING a collector, never naming one: /privacy-policy/ discusses
# analytics providers in prose and stays free to.
Check.register(
  id: "no-analytics-or-telemetry",
  desc: "No page, committed head/layout/script source, or built file loads an analytics, telemetry, or beacon collector"
) do |site|
  collectors = [
    %r{https?://[^"'\s)]*(?:google-analytics\.com|googletagmanager\.com|plausible\.io
       |cloudflareinsights\.com|goatcounter\.com|usefathom\.com|matomo\.(?:cloud|org)
       |mixpanel\.com|amplitude\.com|posthog\.com|hotjar\.com|clarity\.ms
       |segment\.(?:com|io)|simpleanalyticscdn\.com|umami\.is|counter\.dev)}xi,
    /\bgtag\s*\(/,
    /\bdataLayer\s*\.\s*push\s*\(/,
    /\b_paq\s*\.\s*push\s*\(/,
    /\bnavigator\s*\.\s*sendBeacon\s*\(/,
    /\bdata-(?:goatcounter|cf-beacon)\b/i
  ]

  loads_collector = ->(body) { collectors.any? { |pattern| body.match?(pattern) } }

  # Every source that can put a <script> on a page: a markdown page's own raw
  # HTML, the head/layout includes, and any committed JavaScript.
  sources = Dir.glob(File.join(ROOT, "_includes", "**", "*.html")) +
            Dir.glob(File.join(ROOT, "_layouts", "**", "*.html")) +
            Dir.glob(File.join(ROOT, "**", "*.js")) +
            [File.join(ROOT, "_config.yml")]

  sources = sources.select { |f| File.file?(f) }
                   .map { |f| f.sub("#{ROOT}/", "") }
                   .reject { |rel| rel.start_with?(*Site::CONTENT_EXCLUDED_DIRS.map { |d| "#{d}/" }) }
                   .reject { |rel| rel.include?("/node_modules/") }
                   .uniq.sort

  site.fail!("found no head, layout or script source to scan — this assertion examined nothing") if sources.empty?

  offenders = site.pages.select { |page| loads_collector.call(page.body) }.map(&:path)
  offenders += sources.select { |rel| loads_collector.call(site.raw(rel)) }

  # Built output last: it is absent on a checkout that hasn't run `rake
  # check:build`, and the source scan above still reports there.
  offenders += site.html_files.select { |file| loads_collector.call(file.body) }.map(&:path)

  unless offenders.empty?
    site.fail!(
      "analytics/telemetry collector loaded by #{offenders.uniq.join(', ')} — PRD out-of-scope item 9 " \
      "excludes collectors, so adding one is a product decision (a backend, a retention policy and a " \
      "privacy disclosure), not a docs change"
    )
  end
end
