# frozen_string_literal: true

Check.register(
  id: "aux-links-not-template",
  desc: "_config.yml declares real aux_links, not the commented just-the-docs template block",
  covers: ["2.12"]
) do |site|
  raw = site.raw("_config.yml")

  site.fail!("_config.yml still contains a commented aux_links block") if raw =~ /^\s*#\s*aux_links:/

  config = YAML.safe_load(raw)
  aux_links = config["aux_links"]
  site.fail!("_config.yml must declare a non-empty aux_links key") if aux_links.nil? || aux_links.empty?

  aux_links.each_value do |url|
    if url.include?("just-the-docs-template") || url.include?("github.com/just-the-docs")
      site.fail!("aux_links URL #{url} points at a just-the-docs template repository")
    end
  end
end
