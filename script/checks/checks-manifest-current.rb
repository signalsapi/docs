# frozen_string_literal: true

Check.register(
  id: "checks-manifest-current",
  desc: "_data/checks.yml matches the live Check registry",
  covers: ["1.8"]
) do |site|
  site.examining("registered assertions", Check.registry)

  unless ChecksManifest.current?
    site.fail!("_data/checks.yml is stale — run `bundle exec rake check:manifest` to regenerate it")
  end
end
