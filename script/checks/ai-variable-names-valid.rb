# frozen_string_literal: true

# Story 6.6: this symptom page's whole value is naming REAL AI template
# variables, not a plausible-looking guess. Cross-checks its {variable}
# references against the one real source of truth, _data/variables.yml
# (Story 7.4 moved this out of features/ai-variables.md's own prose).
Check.register(
  id: "ai-variable-names-valid",
  desc: "Every {variable} referenced in troubleshooting/ai-filter-too-strict.md is documented in _data/variables.yml",
  covers: ["6.6"]
) do |site|
  page = site.pages.find { |p| p.path == "troubleshooting/ai-filter-too-strict.md" }
  site.fail!("troubleshooting/ai-filter-too-strict.md is missing") unless page

  site.fail!("_data/variables.yml is missing") unless site.data["variables"]
  real_vars = site.data["variables"]["items"].map { |v| v["name"] }
  site.fail!("_data/variables.yml has no variables to compare against") if real_vars.empty?

  offenders = page.body.scan(/\{([a-z_]+)\}/).flatten.uniq.reject { |v| real_vars.include?(v) }

  unless offenders.empty?
    site.fail!("undeclared AI variable reference(s) in troubleshooting/ai-filter-too-strict.md — #{offenders.join(', ')}")
  end
end
