# frozen_string_literal: true

Check.register(
  id: "site-excludes-scaffolding",
  desc: "_config.yml declares exclude: for repo scaffolding, and none of those entries appears under _site/",
  covers: ["2.2"]
) do |site|
  config = YAML.safe_load(site.raw("_config.yml"))
  excludes = config["exclude"]

  site.fail!("_config.yml must declare a non-empty `exclude:` key") if excludes.nil? || excludes.empty?

  excludes.each do |entry|
    path = File.join(ROOT, "_site", entry)
    if File.exist?(path)
      site.fail!("_site/#{entry} must not exist — it is repository scaffolding declared under `exclude:`")
    end
  end
end
