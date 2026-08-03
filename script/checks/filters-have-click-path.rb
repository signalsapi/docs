# frozen_string_literal: true

Check.register(
  id: "filters-have-click-path",
  desc: "Every _data/filters.yml item declares a click_path and a default",
  covers: ["7.6"]
) do |site|
  site.fail!("_data/filters.yml is missing") unless site.data["filters"]

  items = site.data["filters"]["items"]
  site.fail!("_data/filters.yml has no items") if items.nil? || items.empty?

  offenders = []
  items.each_with_index do |item, i|
    label = item["label"] || "item #{i}"
    missing = []
    missing << "click_path" if item["click_path"].to_s.strip.empty?
    missing << "default" if item["default"].to_s.strip.empty?
    offenders << "#{label} is missing: #{missing.join(', ')}" unless missing.empty?
  end

  site.fail!("filter(s) missing required field(s) — #{offenders.join('; ')}") unless offenders.empty?
end
