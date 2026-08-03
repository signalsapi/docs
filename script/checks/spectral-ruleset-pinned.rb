# frozen_string_literal: true

# Story 10.2 pins Spectral with .spectral-version plus the ci.yml install line
# that reads it. That pins the CLI and nothing else: @stoplight/spectral-cli
# declares "@stoplight/spectral-rulesets": ">=1", so the package holding every
# spectral:oas rule floats to whatever is newest at install time.
#
# It is not a theoretical gap. On 2026-08-03 the pinned CLI 6.16.2 aborted
# `rake lint:openapi` outright under rulesets 1.22.6 ("Cannot read properties
# of null (reading 'enum')") and passed clean under 1.22.7, which added the
# `@ != null` guard to duplicated-entry-in-enum's JSONPath. Same pin, opposite
# verdicts, ninety minutes apart. Pinning both versions is what makes the
# Rakefile's "reproduces on a contributor's machine instead of only in CI"
# actually true.
Check.register(
  id: "spectral-ruleset-pinned",
  desc: "the Spectral ruleset version is pinned in .spectral-ruleset-version and installed from it by ci.yml",
  covers: ["10.2"]
) do |site|
  next unless File.exist?(File.join(ROOT, "openapi", "plane-v1.yaml"))

  version_path = File.join(ROOT, ".spectral-ruleset-version")
  unless File.exist?(version_path)
    site.fail!(".spectral-ruleset-version is missing — the spectral:oas rules float to whatever npm resolves")
  end

  pinned = File.read(version_path).strip
  unless pinned.match?(/\A\d+\.\d+\.\d+\z/)
    site.fail!(".spectral-ruleset-version must hold one exact version, got #{pinned.inspect}")
  end

  ci = site.raw(".github/workflows/ci.yml")

  unless ci.include?("@stoplight/spectral-rulesets@")
    site.fail!(
      ".github/workflows/ci.yml installs @stoplight/spectral-cli without pinning " \
      "@stoplight/spectral-rulesets — the rules the lint enforces are unpinned"
    )
  end

  unless ci.include?(".spectral-ruleset-version")
    site.fail!(
      ".github/workflows/ci.yml pins the Spectral ruleset to a literal instead of reading " \
      ".spectral-ruleset-version, so the two can drift apart"
    )
  end
end
