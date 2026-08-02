# frozen_string_literal: true

REQUIRED_PROVIDER_KEYS = %w[name mobile_support filters credential_shape signup_url affiliate cost].freeze
ALLOWED_FILTER_KEYS = %w[title country city skills department seniority].freeze
ALLOWED_FILTER_VALUES = %w[at_source after_fetch unsupported].freeze
ALLOWED_CREDENTIAL_SHAPES = %w[api_key client_id_and_secret key_and_secret].freeze

Check.register(
  id: "providers-schema",
  desc: "Every _data/providers.yml item declares exactly the required keys, with valid filter and credential values",
  covers: ["7.2"]
) do |site|
  site.fail!("_data/providers.yml is missing") unless site.data["providers"]

  items = site.data["providers"]["items"]
  site.fail!("_data/providers.yml has no items") if items.nil? || items.empty?

  offenders = []

  items.each_with_index do |item, i|
    label = item["name"] || "item #{i}"

    missing = REQUIRED_PROVIDER_KEYS - item.keys
    offenders << "#{label} is missing key(s): #{missing.join(', ')}" unless missing.empty?

    unknown = item.keys - REQUIRED_PROVIDER_KEYS
    offenders << "#{label} declares unknown key(s): #{unknown.join(', ')}" unless unknown.empty?

    unless ALLOWED_CREDENTIAL_SHAPES.include?(item["credential_shape"])
      offenders << "#{label} has an invalid credential_shape: #{item['credential_shape'].inspect}"
    end

    filters = item["filters"]
    if filters.is_a?(Hash)
      missing_filters = ALLOWED_FILTER_KEYS - filters.keys
      offenders << "#{label} is missing filter(s): #{missing_filters.join(', ')}" unless missing_filters.empty?

      unknown_filters = filters.keys - ALLOWED_FILTER_KEYS
      offenders << "#{label} declares unknown filter(s): #{unknown_filters.join(', ')}" unless unknown_filters.empty?

      invalid_values = filters.reject { |_k, v| ALLOWED_FILTER_VALUES.include?(v) }
      offenders << "#{label} has invalid filter value(s): #{invalid_values.inspect}" unless invalid_values.empty?
    else
      offenders << "#{label}'s filters: is not a mapping"
    end
  end

  site.fail!("providers schema violation(s) — #{offenders.join('; ')}") unless offenders.empty?
end
