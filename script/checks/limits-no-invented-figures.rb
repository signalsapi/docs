# frozen_string_literal: true

# limits.md's own template never types a figure literally — every number
# reaches the page through {{ item.value }}, sourced from _data/limits.yml.
# Stripping Liquid tags from the raw source and scanning what's left for a
# digit catches a future edit that bypasses the data file.
Check.register(
  id: "limits-no-invented-figures",
  desc: "Every numeric quantity on limits.md is traceable to _data/limits.yml or an owner marker",
  covers: ["9.6"]
) do |site|
  page = site.pages.find { |p| p.path == "limits.md" }
  site.fail!("limits.md is missing") unless page

  offenders = []
  page.body.each_line do |line|
    next if line.include?("TODO(owner")

    outside_liquid = line.gsub(/\{%.*?%\}/, "").gsub(/\{\{.*?\}\}/, "")
    outside_liquid.scan(/\d+/).each { |num| offenders << "#{num.inspect} in #{line.strip.inspect}" }
  end

  unless offenders.empty?
    site.fail!("limits.md has hand-typed numeric quantity(ies) not traceable to _data/limits.yml or an owner marker — #{offenders.join('; ')}")
  end
end
