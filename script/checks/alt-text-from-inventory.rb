# frozen_string_literal: true

require "cgi"

# Story 11.2 renders every screenshot's alt attribute from _data/screenshots.yml
# via _includes/screenshot.html rather than a hand-typed string — this reads
# the BUILT html (proving the include actually ran) and fails if any image's
# rendered alt ever diverges from what the inventory records for it.
Check.register(
  id: "alt-text-from-inventory",
  desc: "every built image's alt attribute exactly matches the value recorded for it in _data/screenshots.yml",
  covers: ["11.2"]
) do |site|
  items = site.data.dig("screenshots", "items") || []
  site.fail!("_data/screenshots.yml has no items") if items.empty?

  expected_by_path = items.each_with_object({}) { |i, h| h[i["path"]] = i["alt"] }

  mismatches = []

  site.html_files.each do |file|
    file.body.scan(/<img\s+src="\/([^"]+)"\s+alt="([^"]*)"/).each do |src, built_alt|
      expected = expected_by_path[src]
      next unless expected # an image absent from the inventory is screenshot-inventory-complete's concern, not this one's

      expected_escaped = CGI.escapeHTML(expected)
      next if built_alt == expected_escaped

      mismatches << "#{file.path}: #{src} has alt #{built_alt.inspect}, inventory records #{expected.inspect}"
    end
  end

  site.fail!("built alt text diverges from the inventory — #{mismatches.join('; ')}") unless mismatches.empty?
end
