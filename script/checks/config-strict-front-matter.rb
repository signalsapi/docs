# frozen_string_literal: true

require "yaml"

Check.register(
  id: "config-strict-front-matter",
  desc: "_config.yml declares strict_front_matter: true",
  covers: ["1.2"]
) do |site|
  config = YAML.safe_load(site.raw("_config.yml"))
  unless config["strict_front_matter"] == true
    site.fail!("_config.yml must declare `strict_front_matter: true`")
  end
end
