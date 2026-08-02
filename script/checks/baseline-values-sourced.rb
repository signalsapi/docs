# frozen_string_literal: true

Check.register(
  id: "baseline-values-sourced",
  desc: "Every value in _data/baseline.yml is an integer, a date, a boolean, or a well-formed TODO(owner: handle): marker",
  covers: ["3.1"]
) do |site|
  marker_re = /\ATODO\(owner:\s*\S[^)]*\):\s*\S/
  data = site.data["baseline"]

  site.fail!("_data/baseline.yml is missing or empty") if data.nil? || data.empty?

  data.each do |key, value|
    next if value.is_a?(Integer) || value.is_a?(Date) || [true, false].include?(value)
    next if value.is_a?(String) && value.match?(marker_re)

    site.fail!("_data/baseline.yml##{key} is not an integer, date, boolean, or well-formed owner marker: #{value.inspect}")
  end
end
