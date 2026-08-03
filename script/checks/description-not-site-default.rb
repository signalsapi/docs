# frozen_string_literal: true

Check.register(
  id: "description-not-site-default",
  desc: "No page's description equals _config.yml's site-level description",
  covers: ["5.3"]
) do |site|
  site_description = YAML.safe_load(site.raw("_config.yml"))["description"]

  offenders = site.pages.select { |p| p.front_matter["description"] == site_description }

  unless offenders.empty?
    site.fail!("page(s) still using the site-level description — #{offenders.map(&:path).join(', ')}")
  end
end
