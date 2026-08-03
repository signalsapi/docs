# frozen_string_literal: true

require "cgi"

# Story 11.8 renders whats-new/index.md entirely from _data/changelog.yml —
# this reads the BUILT page and fails if any entry's text can't be found in
# it, proving the render loop actually emitted every one rather than
# silently dropping some to a broken sort, filter, or template edit.
# Comparison strips everything but letters/digits (case-folded) because
# kramdown rewrites straight quotes/-- into smart quotes/en-dashes and
# HTML-escapes bare "->" arrows into literal "&gt;" text — differences that
# have nothing to do with whether the entry is actually present.
Check.register(
  id: "changelog-page-complete",
  desc: "every _data/changelog.yml entry appears in the built changelog page",
  covers: ["11.8"]
) do |site|
  items = site.data.dig("changelog", "items") || []
  site.fail!("_data/changelog.yml has no items") if items.empty?

  built_path = File.join(ROOT, "_site", "whats-new", "index.html")
  site.fail!("_site/whats-new/index.html is missing") unless File.exist?(built_path)

  normalize = lambda do |text|
    CGI.unescapeHTML(text).downcase.gsub(/[^a-z0-9\s]/, "").gsub(/\s+/, " ").strip
  end

  page_text = normalize.call(File.read(built_path).gsub(/<[^>]+>/, " "))

  missing = items.reject do |item|
    plain = item["summary"].gsub(/\*\*/, "").gsub(/\[([^\]]*)\]\([^)]*\)/, '\1')
    snippet = normalize.call(plain[0, 60])
    page_text.include?(snippet)
  end

  unless missing.empty?
    site.fail!("changelog entries missing from the built page — #{missing.map { |i| i['summary'][0, 40] }.join('; ')}")
  end
end
