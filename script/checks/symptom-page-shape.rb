# frozen_string_literal: true

Check.register(
  id: "symptom-page-shape",
  desc: "Every page_type: symptom page carries the five required symptom headings and a non-empty search_aliases",
  covers: ["6.2"]
) do |site|
  required_headings = [
    "## What you are seeing",
    "## Most likely cause",
    "## Check this first",
    "## Other causes",
    "## Still stuck"
  ]

  offenders = []

  site.examining("symptom pages", site.pages.select { |p| p.front_matter["page_type"] == "symptom" }).each do |page|
    missing = required_headings.reject { |heading| page.body.include?(heading) }
    offenders << "#{page.path} is missing: #{missing.join(', ')}" unless missing.empty?

    aliases = page.front_matter["search_aliases"]
    offenders << "#{page.path} declares an empty search_aliases" if aliases.nil? || aliases.empty?
  end

  site.fail!("symptom page shape violation(s) — #{offenders.join('; ')}") unless offenders.empty?
end
