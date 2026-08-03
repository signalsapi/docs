# frozen_string_literal: true

# Story 7.5: the "Available integrations" list now renders from
# _data/integrations.yml, so it's complete by construction — this
# assertion's remaining job is catching a future "## Integrating with X"
# prose section added without a matching data item (exactly how Zoho and
# Firefish drifted out of the numbered list before this story).
Check.register(
  id: "integrations-complete",
  desc: "Every destination named on features/integrations.md has an item in _data/integrations.yml",
  covers: ["7.5"]
) do |site|
  page = site.pages.find { |p| p.path == "features/integrations.md" }
  site.fail!("features/integrations.md is missing") unless page

  heading_names = page.body.scan(/^## Integrating with (.+)$/).flatten.map(&:strip)

  site.fail!("_data/integrations.yml is missing") unless site.data["integrations"]
  data_names = site.data["integrations"]["items"].map { |i| i["name"] }

  missing = heading_names.reject { |n| data_names.include?(n) }
  unless missing.empty?
    site.fail!("destination(s) named on features/integrations.md but absent from _data/integrations.yml — #{missing.join(', ')}")
  end
end
