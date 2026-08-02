# frozen_string_literal: true

# AD-11: the plugin budget is three. The overhaul adds exactly jekyll-sitemap,
# jekyll-redirect-from and jekyll-seo-tag across several stories; this caps
# _config.yml's plugins: list at a subset of that named set, never beyond it.
Check.register(
  id: "plugin-budget",
  desc: "_config.yml's plugins: list is a subset of {jekyll-sitemap, jekyll-redirect-from, jekyll-seo-tag}",
  covers: ["2.14"]
) do |site|
  allowed = %w[jekyll-sitemap jekyll-redirect-from jekyll-seo-tag]
  config = YAML.safe_load(site.raw("_config.yml"))
  plugins = config["plugins"] || []

  extra = plugins - allowed
  site.fail!("_config.yml lists plugin(s) outside the three-plugin budget: #{extra.join(', ')}") unless extra.empty?
end
