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

  # The inventory-tracked <img> tags are the subject, not the built pages they
  # sit on. This recognises exactly one rendering — src immediately followed by
  # alt — so a layout that puts any attribute between them, or an include that
  # stops emitting alt at all, matches nothing, skips every image, and passes
  # green while still reporting a full page count (signalsapi-4324).
  tracked = site.examining(
    "built images tracked by the screenshot inventory",
    site.html_files.flat_map do |file|
      # An image absent from the inventory is screenshot-inventory-complete's
      # concern, not this one's, so it is not part of this subject either.
      file.body.scan(/<img\s+src="\/([^"]+)"\s+alt="([^"]*)"/)
          .select { |src, _built_alt| expected_by_path.key?(src) }
          .map { |src, built_alt| [file.path, src, built_alt] }
    end
  )

  mismatches = tracked.filter_map do |path, src, built_alt|
    expected = expected_by_path[src]
    next if built_alt == CGI.escapeHTML(expected)

    "#{path}: #{src} has alt #{built_alt.inspect}, inventory records #{expected.inspect}"
  end

  site.fail!("built alt text diverges from the inventory — #{mismatches.join('; ')}") unless mismatches.empty?
end
