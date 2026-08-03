# frozen_string_literal: true

# Story 1.10: the gate has to reach the same verdict in CI as on a laptop.
# It did not. `bundler-cache: true` installs gems into `vendor/bundle/` inside
# the checkout, so in CI — and only in CI — twenty-one gem spec fixtures and
# CHANGELOGs appeared under `**/*.md` and were audited as if they were our
# pages: eleven assertions reddened at once, and page-budget counted 78 pages
# against a ceiling of 57. Jekyll ignores these trees through its own default
# excludes; Site must ignore them too, or the gate only passes where the
# dependencies happen to live outside the repository.
Check.register(
  id: "checks-ignore-dependency-trees",
  desc: "Site excludes third-party dependency trees, so the gate reads the same page set in CI as locally",
  covers: ["1.10"]
) do |site|
  required = %w[vendor node_modules]

  missing = required - Site::CONTENT_EXCLUDED_DIRS
  unless missing.empty?
    site.fail!("Site::CONTENT_EXCLUDED_DIRS must exclude dependency tree(s): #{missing.join(', ')}")
  end

  leaked = site.pages.map(&:path).select { |p| p.start_with?(*required.map { |d| "#{d}/" }) }
  site.fail!("dependency-tree file(s) parsed as pages: #{leaked.join(', ')}") unless leaked.empty?
end
