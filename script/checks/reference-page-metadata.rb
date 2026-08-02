# frozen_string_literal: true

Check.register(
  id: "reference-page-metadata",
  desc: "Every page_type: reference page declares a verified_on date and an owner",
  covers: ["6.9"]
) do |site|
  offenders = []

  site.pages.select { |p| p.front_matter["page_type"] == "reference" }.each do |page|
    missing = []
    missing << "verified_on" unless page.front_matter["verified_on"]
    missing << "owner" unless page.front_matter["owner"]
    offenders << "#{page.path} is missing: #{missing.join(', ')}" unless missing.empty?
  end

  site.fail!("reference page metadata violation(s) — #{offenders.join('; ')}") unless offenders.empty?
end
