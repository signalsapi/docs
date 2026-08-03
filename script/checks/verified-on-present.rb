# frozen_string_literal: true

# Story 9.1 generalizes reference-page-metadata (6.9, page_type: reference
# only) to every published page — a stale fact is just as unowned on a
# feature page as on a reference page.
Check.register(
  id: "verified-on-present",
  desc: "Every published page declares verified_on and owner, with verified_on never in the future",
  covers: %w[6.9 9.1]
) do |site|
  today = Date.today
  offenders = []

  site.pages.each do |page|
    missing = []
    missing << "verified_on" unless page.front_matter["verified_on"]
    missing << "owner" unless page.front_matter["owner"]
    offenders << "#{page.path} is missing: #{missing.join(', ')}" unless missing.empty?

    verified_on = page.front_matter["verified_on"]
    next unless page.front_matter.key?("verified_on")

    if !verified_on.is_a?(Date)
      offenders << "#{page.path}: verified_on #{verified_on.inspect} is not a valid date"
    elsif verified_on > today
      offenders << "#{page.path}: verified_on #{verified_on} is in the future"
    end
  end

  site.fail!("verified_on/owner violation(s) — #{offenders.join('; ')}") unless offenders.empty?
end
