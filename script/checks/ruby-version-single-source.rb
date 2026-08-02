# frozen_string_literal: true

Check.register(
  id: "ruby-version-single-source",
  desc: "Ruby is pinned by .ruby-version only — no inline ruby-version: in CI, no `ruby` directive in the Gemfile",
  covers: ["1.9"]
) do |site|
  site.fail!(".ruby-version is missing from the repository root") unless File.exist?(File.join(ROOT, ".ruby-version"))

  %w[.github/workflows/ci.yml .github/workflows/pages.yml].each do |workflow|
    path = File.join(ROOT, workflow)
    next unless File.exist?(path)

    if File.read(path) =~ /^\s*ruby-version:\s*['"]?[\d.]/
      site.fail!("#{workflow} declares an inline ruby-version: key — remove it so ruby/setup-ruby reads .ruby-version")
    end
  end

  if File.read(File.join(ROOT, "Gemfile")) =~ /^\s*ruby\s+['"]/
    site.fail!("Gemfile declares a `ruby` directive — Ruby is pinned by .ruby-version only (AD-13)")
  end
end
