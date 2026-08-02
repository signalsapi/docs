# frozen_string_literal: true

Check.register(
  id: "data-verified-on-parses",
  desc: "Every _data/*.yml file's meta.verified_on is a valid ISO date",
  covers: ["7.1"]
) do |site|
  offenders = []

  site.data.each do |name, data|
    next unless data.is_a?(Hash) && data["meta"].is_a?(Hash)

    offenders << "_data/#{name}.yml" unless data["meta"]["verified_on"].is_a?(Date)
  end

  site.fail!("meta.verified_on is not an ISO date in: #{offenders.join(', ')}") unless offenders.empty?
end
