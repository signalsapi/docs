# frozen_string_literal: true

# Story 6.5: features/remove-duplicate-signals.md documented the Duplicates
# control entirely inside two screenshots with empty alt text — invisible to
# search, screen readers, and anyone skimming raw markdown. Each control
# below must be stated as real text somewhere in the site; add to this list
# whenever a future story pulls another image-only control out into text.
#
# Story 11.3 added four more (Domains, and the three Select decision-makers
# fields) rendered from _data/controls.yml via _includes/controls-table.html
# rather than hand-typed — that text exists only in the BUILT output, not in
# any page's raw source, so a control is now "documented as real text" if it
# appears in either place.
DOCUMENTED_CONTROLS = [
  "Within this list",
  "Among all lists",
  "Domains",
  "Job titles of decision-makers",
  "Person location",
  "Max decision-makers per company"
].freeze

Check.register(
  id: "no-instruction-only-in-image",
  desc: "Every documented control name appears in real page text, not only inside an image's alt attribute or filename",
  covers: %w[6.5 11.3]
) do |site|
  offenders = DOCUMENTED_CONTROLS.reject do |control|
    found_in_source = site.pages.any? do |page|
      text_only = page.body.gsub(/<img\b[^>]*>/i, "")
      text_only.include?(control)
    end

    found_in_source || site.html_files.any? { |file| file.body.include?(control) }
  end

  unless offenders.empty?
    site.fail!("control name(s) not documented as real text anywhere: #{offenders.join(', ')}")
  end
end
