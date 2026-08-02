# frozen_string_literal: true

# GitBook's exporter left "mention" as the literal title attribute on internal
# cross-reference links, e.g. [ai-variables.md](ai-variables.md "mention") -
# a dead link 21 months before Story 2.7 repaired the one real instance.
Check.register(
  id: "no-gitbook-mention-artifacts",
  desc: "No .md file contains a Markdown link whose title attribute is the literal string \"mention\"",
  covers: ["2.7"]
) do |site|
  offenders = site.pages.select { |p| site.raw(p.path) =~ /\[[^\]]*\]\([^)]*"mention"\)/ }

  unless offenders.empty?
    site.fail!("GitBook \"mention\" link artifact found in: #{offenders.map(&:path).join(', ')}")
  end
end
