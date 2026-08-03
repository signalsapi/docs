# frozen_string_literal: true

# Story 8.1: a search-result snippet is truncated well past 160 characters
# and looks sparse under 50, so the bound is enforced on its own — Story 5.2
# only checks that description is present at all.
Check.register(
  id: "description-length",
  desc: "Every page's description is between 50 and 160 characters, snippet-ready for a search result",
  covers: ["8.1"]
) do |site|
  offenders = site.examining("pages declaring a description", site.pages.select { |p| p.front_matter.key?("description") })
                  .reject { |p| p.front_matter["description"].to_s.length.between?(50, 160) }

  unless offenders.empty?
    details = offenders.map { |p| "#{p.path}: #{p.front_matter['description'].to_s.length} characters" }
    site.fail!("description(s) outside the 50-160 character range — #{details.join('; ')}")
  end
end
