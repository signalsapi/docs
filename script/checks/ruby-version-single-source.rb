# frozen_string_literal: true

Check.register(
  id: "ruby-version-single-source",
  desc: "Ruby is pinned by .ruby-version only — no inline ruby-version: in CI, no `ruby` directive in the Gemfile",
  covers: ["1.9"]
) do |site|
  site.fail!(".ruby-version is missing from the repository root") unless site.exist?(".ruby-version")

  # Every workflow, not the two that happened to exist when AD-13 landed: the
  # ci.yml/pages.yml pair this used to name was an exhaustive list at 8d31257,
  # then went stale in silence when link-check-nightly.yml arrived setting Ruby
  # up of its own accord — the same blind subject set signalsapi-4306 reported
  # one assertion over.
  site.examining("workflow files", site.workflows).each do |workflow|
    if site.raw(workflow) =~ /^\s*ruby-version:\s*['"]?[\d.]/
      site.fail!("#{workflow} declares an inline ruby-version: key — remove it so ruby/setup-ruby reads .ruby-version")
    end
  end

  if site.raw("Gemfile") =~ /^\s*ruby\s+['"]/
    site.fail!("Gemfile declares a `ruby` directive — Ruby is pinned by .ruby-version only (AD-13)")
  end
end
