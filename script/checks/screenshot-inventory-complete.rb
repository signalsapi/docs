# frozen_string_literal: true

# Story 11.1: _data/screenshots.yml is the one place that knows what every
# image in the repository shows, when it was captured, and which page owns
# it — a prerequisite for telling a current screenshot from a stale one.
# This keeps the inventory honest in both directions: every real image file
# has an item, and every item points at a file that actually exists.
Check.register(
  id: "screenshot-inventory-complete",
  desc: "every image file has an item in _data/screenshots.yml, and every item's path resolves to a real file",
  covers: ["11.1"]
) do |site|
  image_extensions = %w[png jpg jpeg gif svg webp]

  real_images = Dir.glob(File.join(ROOT, "**", "*.{#{image_extensions.join(',')}}"))
                    .reject { |f| f.sub("#{ROOT}/", "").start_with?(*Site::CONTENT_EXCLUDED_DIRS.map { |d| "#{d}/" }) }
                    .reject { |f| f.include?("/node_modules/") }
                    .map { |f| f.sub("#{ROOT}/", "") }
                    .sort

  items = site.data.dig("screenshots", "items") || []
  site.fail!("_data/screenshots.yml has no items") if items.empty?

  item_paths = items.map { |i| i["path"] }

  offenders = []

  missing_items = real_images - item_paths
  offenders << "image file(s) with no item — #{missing_items.join(', ')}" unless missing_items.empty?

  broken_paths = items.reject { |i| File.exist?(File.join(ROOT, i["path"].to_s)) }.map { |i| i["path"] }
  offenders << "item(s) naming a path that does not exist — #{broken_paths.join(', ')}" unless broken_paths.empty?

  site.fail!("screenshot inventory violation(s) — #{offenders.join('; ')}") unless offenders.empty?
end
