# frozen_string_literal: true

# Story 7.9: the comparison page's two tables are Liquid loops over
# site.data.providers.items, so a raw table row should only ever contain
# Liquid tags, never a hand-typed provider name that could drift from the
# data file.
PROVIDER_COMPARISON_PAGE = "features/compare-people-data-providers.md"

Check.register(
  id: "providers-not-duplicated-in-prose",
  desc: "The provider comparison page's tables render every provider name from _data/providers.yml, not hand-written",
  covers: ["7.9"]
) do |site|
  site.fail!("_data/providers.yml is missing") unless site.data["providers"]
  site.fail!("#{PROVIDER_COMPARISON_PAGE} is missing") unless site.pages.any? { |p| p.path == PROVIDER_COMPARISON_PAGE }

  provider_names = site.data["providers"]["items"].map { |p| p["name"] }
  offenders = []

  site.raw(PROVIDER_COMPARISON_PAGE).each_line do |line|
    stripped = line.strip
    next unless stripped.start_with?("|")
    next if stripped.match?(/\A\|[\s:|-]+\|\z/) # header separator row
    next if stripped.include?("{%") || stripped.include?("{{") # Liquid-driven row

    provider_names.each { |name| offenders << name if stripped.include?(name) }
  end

  unless offenders.empty?
    site.fail!("provider name(s) hand-written into a table row instead of rendered from data — #{offenders.uniq.join(', ')}")
  end
end
