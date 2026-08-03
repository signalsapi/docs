# frozen_string_literal: true

# Story 11.4: the screenshot inventory (Story 11.1) only protects images that
# were already declared when it was built — nothing stopped a future page
# from adding a raw <img> tag with hand-typed (or empty) alt text and no
# entry at all. This reads the BUILT site for every referenced image and
# fails if it has no _data/screenshots.yml item, or that item has no
# non-empty alt text or no capture_date — the screenshot debt this epic just
# paid down cannot quietly rebuild itself.
Check.register(
  id: "image-requires-inventory-entry",
  desc: "every image referenced in the built site has an _data/screenshots.yml item with non-empty alt text and a capture date",
  covers: ["11.4"]
) do |site|
  items = site.data.dig("screenshots", "items") || []
  by_path = items.each_with_object({}) { |i, h| h[i["path"]] = i }

  # The references are the subject, not the built pages they were found on: a
  # rendering this pattern no longer recognises — an attribute before src, a
  # different quoting, a move to <picture>/<source> — leaves every image
  # unaudited while the assertion still reports a full page count and passes,
  # which is the debt this check exists to stop rebuilding (signalsapi-4324).
  references = site.examining(
    "built image references",
    site.html_files.flat_map do |file|
      file.body.scan(/<img\s+src="\/([^"]+)"/).flatten.uniq.map { |src| [file.path, src] }
    end
  )

  offenders = references.flat_map do |path, src|
    item = by_path[src]
    next ["#{path}: #{src} has no _data/screenshots.yml item"] unless item

    problems = []
    problems << "#{path}: #{src}'s item has empty alt text" if item["alt"].to_s.strip.empty?
    problems << "#{path}: #{src}'s item has no capture_date" unless item["capture_date"]
    problems
  end

  site.fail!("image reference violation(s) — #{offenders.join('; ')}") unless offenders.empty?
end
