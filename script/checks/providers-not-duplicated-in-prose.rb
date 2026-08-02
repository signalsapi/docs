# frozen_string_literal: true

# Stories 7.9-7.10: these pages' provider tables are Liquid loops over
# site.data.providers.items, so a raw table row should only ever contain
# Liquid tags, never a hand-typed provider name that could drift from the
# data file.
PROVIDER_TABLE_PAGES = %w[
  features/compare-people-data-providers.md
  features/bring-your-own-people-provider.md
].freeze

Check.register(
  id: "providers-not-duplicated-in-prose",
  desc: "Every page's provider table renders provider names from _data/providers.yml, not hand-written",
  covers: %w[7.9 7.10]
) do |site|
  site.fail!("_data/providers.yml is missing") unless site.data["providers"]

  provider_names = site.data["providers"]["items"].map { |p| p["name"] }
  offenders = []

  PROVIDER_TABLE_PAGES.each do |path|
    site.fail!("#{path} is missing") unless site.pages.any? { |p| p.path == path }

    site.raw(path).each_line do |line|
      stripped = line.strip
      next if stripped.match?(/\A\|[\s:|-]+\|\z/) # header separator row

      # Strip Liquid tags before checking a row's shape — a generated row
      # starts with a {% for %} tag rather than "|", and can legitimately
      # carry a tag (e.g. an include) alongside a hand-typed name elsewhere
      # on the same line.
      outside_liquid = stripped.gsub(/\{%.*?%\}/, "").gsub(/\{\{.*?\}\}/, "")
      next unless outside_liquid.include?("|")

      provider_names.each { |name| offenders << "#{path}: #{name}" if outside_liquid.include?(name) }
    end
  end

  unless offenders.empty?
    site.fail!("provider name(s) hand-written into a table row instead of rendered from data — #{offenders.uniq.join(', ')}")
  end
end
