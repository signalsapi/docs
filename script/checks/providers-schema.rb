# frozen_string_literal: true

REQUIRED_PROVIDER_KEYS = %w[name mobile_support linkedin_profile headline filters credential_shape signup_url affiliate cost source].freeze
ALLOWED_FILTER_KEYS = %w[title country city skills department seniority].freeze
ALLOWED_FILTER_VALUES = %w[at_source after_fetch unsupported].freeze
ALLOWED_CREDENTIAL_SHAPES = %w[api_key client_id_and_secret key_and_secret].freeze
ALLOWED_LINKEDIN_PROFILE_VALUES = %w[full partial].freeze

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

    unless ALLOWED_LINKEDIN_PROFILE_VALUES.include?(item["linkedin_profile"])
      offenders << "#{label} has an invalid linkedin_profile: #{item['linkedin_profile'].inspect}"
    end

    unless [true, false].include?(item["headline"])
      offenders << "#{label} has a non-boolean headline: #{item['headline'].inspect}"
    end

    # A cost is a third party's list price, so it is only worth anything with the
    # page it was read off and the day it was read there — otherwise it is a claim
    # nobody can re-check and it silently rots the first time that provider
    # re-prices. This holds for a placeholder too: the marker still has to say
    # which page was tried.
    source = item["source"]
    if !source.is_a?(String) || !source.match?(%r{https://\S}) || !source.match?(/\d{4}-\d{2}-\d{2}/)
      offenders << "#{label}'s source: must name the URL the cost was read from and the ISO date it was read, got: #{source.inspect}"
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
