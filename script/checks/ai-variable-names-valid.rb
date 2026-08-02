# frozen_string_literal: true

# Story 6.6: this symptom page's whole value is naming REAL AI template
# variables, not a plausible-looking guess. Cross-checks its {variable}
# references against the one real source of truth, features/ai-variables.md.
Check.register(
  id: "ai-variable-names-valid",
  desc: "Every {variable} referenced in troubleshooting/ai-filter-too-strict.md is documented on AI variables",
  covers: ["6.6"]
) do |site|
  page = site.pages.find { |p| p.path == "troubleshooting/ai-filter-too-strict.md" }
  site.fail!("troubleshooting/ai-filter-too-strict.md is missing") unless page

  real_vars = site.raw("features/ai-variables.md").scan(/^\*\s+(\S+)/).flatten.map { |v| v.delete("\\") }
  site.fail!("features/ai-variables.md has no variables to compare against") if real_vars.empty?

  offenders = page.body.scan(/\{([a-z_]+)\}/).flatten.uniq.reject { |v| real_vars.include?(v) }

  unless offenders.empty?
    site.fail!("undeclared AI variable reference(s) in troubleshooting/ai-filter-too-strict.md — #{offenders.join(', ')}")
  end
end
