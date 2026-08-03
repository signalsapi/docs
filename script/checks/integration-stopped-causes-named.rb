# frozen_string_literal: true

Check.register(
  id: "integration-stopped-causes-named",
  desc: "troubleshooting/integration-stopped.md names both the manual-approval and credential causes",
  covers: ["6.8"]
) do |site|
  page = site.pages.find { |p| p.path == "troubleshooting/integration-stopped.md" }
  site.fail!("troubleshooting/integration-stopped.md is missing") unless page

  required_terms = ["Manual Approval", "credential"]
  missing = required_terms.reject { |term| page.body.include?(term) }

  unless missing.empty?
    site.fail!("troubleshooting/integration-stopped.md is missing required term(s): #{missing.join(', ')}")
  end
end
