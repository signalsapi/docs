# frozen_string_literal: true

# Story 6.10: one address, named once, on support.md. Fenced code blocks
# are stripped before scanning so illustrative example data (a sample CSV
# export row, say) isn't mistaken for a real contact address.
Check.register(
  id: "single-support-address",
  desc: "No page outside support.md and the policy pages contains an email address",
  covers: ["6.10"]
) do |site|
  exempt_paths = %w[support.md privacy-policy.md tos.md]

  offenders = site.pages.reject { |p| exempt_paths.include?(p.path) }.select do |page|
    text_only = page.body.gsub(/```.*?```/m, "")
    text_only.match?(/[\w.+-]+@[\w-]+\.[a-z]{2,}/i)
  end

  unless offenders.empty?
    site.fail!("email address found outside support.md and the policy pages — #{offenders.map(&:path).join(', ')}")
  end
end
