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

  offenders = []

  site.html_files.each do |file|
    file.body.scan(/<img\s+src="\/([^"]+)"/).flatten.uniq.each do |src|
      item = by_path[src]
      unless item
        offenders << "#{file.path}: #{src} has no _data/screenshots.yml item"
        next
      end

      offenders << "#{file.path}: #{src}'s item has empty alt text" if item["alt"].to_s.strip.empty?
      offenders << "#{file.path}: #{src}'s item has no capture_date" unless item["capture_date"]
    end
  end

  site.fail!("image reference violation(s) — #{offenders.join('; ')}") unless offenders.empty?
end
