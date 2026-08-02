# frozen_string_literal: true

Check.register(
  id: "variables-reference-providers",
  desc: "Every provider named in _data/variables.yml exists in _data/providers.yml",
  covers: ["7.4"]
) do |site|
  site.fail!("_data/providers.yml is missing") unless site.data["providers"]
  site.fail!("_data/variables.yml is missing") unless site.data["variables"]

  valid_providers = site.data["providers"]["items"].map { |p| p["name"] }

  offenders = []
  site.data["variables"]["items"].each do |item|
    (item["providers"] || []).each do |provider|
      offenders << "#{item['name']}: #{provider}" unless valid_providers.include?(provider)
    end
  end

  unless offenders.empty?
    site.fail!("variable(s) name a provider absent from _data/providers.yml — #{offenders.join(', ')}")
  end
end
