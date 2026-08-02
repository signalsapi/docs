# frozen_string_literal: true

Check.register(
  id: "pricing-figures-sourced",
  desc: "Every _data/pricing.yml item declares a value and a source",
  covers: ["7.7"]
) do |site|
  site.fail!("_data/pricing.yml is missing") unless site.data["pricing"]

  items = site.data["pricing"]["items"]
  site.fail!("_data/pricing.yml has no items") if items.nil? || items.empty?

  offenders = []
  items.each_with_index do |item, i|
    label = item["name"] || "item #{i}"
    offenders << "#{label} is missing a value" if item["value"].to_s.strip.empty?
    offenders << "#{label} is missing a source" if item["source"].to_s.strip.empty?
  end

  site.fail!("pricing item(s) missing required field(s) — #{offenders.join('; ')}") unless offenders.empty?
end
