# frozen_string_literal: true

Check.register(
  id: "ruby-version-single-source",
  desc: "Ruby is pinned by .ruby-version only — no inline ruby-version: in CI, no `ruby` directive in the Gemfile",
  covers: ["1.9"]
) do |site|
  site.fail!(".ruby-version is missing from the repository root") unless site.exist?(".ruby-version")

  %w[.github/workflows/ci.yml .github/workflows/pages.yml].each do |workflow|
    next unless site.exist?(workflow)

    if site.raw(workflow) =~ /^\s*ruby-version:\s*['"]?[\d.]/
      site.fail!("#{workflow} declares an inline ruby-version: key — remove it so ruby/setup-ruby reads .ruby-version")
    end
  end

  if site.raw("Gemfile") =~ /^\s*ruby\s+['"]/
    site.fail!("Gemfile declares a `ruby` directive — Ruby is pinned by .ruby-version only (AD-13)")
  end
end
