# frozen_string_literal: true

# Story 10.8 replaces "email us and wait" with "build against what's already
# published" (the specification, the fixtures, the mock) plus an optional,
# non-blocking waitlist mention. This bans the GATING phrasing — emailing
# Support presented as the required next step to obtain access, a base URL,
# or a key — not every mention of Support (troubleshooting, hosting
# interest, and an optional waitlist CTA are all still fine, since none of
# them block a reader from doing something productive today).
Check.register(
  id: "no-email-for-access",
  desc: "No page instructs the reader to email in order to obtain access, a base URL, or a key",
  covers: ["10.8"]
) do |site|
  gating_patterns = [
    /\bcontact \[?Support\]?[^.]*\bto get set up\b/i,
    /\bwe (?:will )?issue (?:your|both)\b/i,
    /\bcontact \[?Support\]?[^.]*\b(?:issue|obtain)[^.]*\b(?:key|base url)\b/i,
    /\bemail\b[^.]*\bto (?:get|obtain|receive)\b[^.]*\b(?:access|key|base url)\b/i
  ]

  offenders = site.pages.select { |page| gating_patterns.any? { |pattern| page.body =~ pattern } }

  unless offenders.empty?
    site.fail!("page(s) instruct emailing in order to obtain access, a base URL, or a key — #{offenders.map(&:path).join(', ')}")
  end
end
