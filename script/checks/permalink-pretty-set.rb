# frozen_string_literal: true

Check.register(
  id: "permalink-pretty-set",
  desc: "_config.yml declares permalink: pretty",
  covers: ["2.3"]
) do |site|
  config = YAML.safe_load(site.raw("_config.yml"))

  unless config["permalink"] == "pretty"
    site.fail!("_config.yml must declare `permalink: pretty`")
  end
end
