# frozen_string_literal: true

# Story 6.5: features/remove-duplicate-signals.md documented the Duplicates
# control entirely inside two screenshots with empty alt text — invisible to
# search, screen readers, and anyone skimming raw markdown. Each control
# below must be stated as real text somewhere in the site; add to this list
# whenever a future story pulls another image-only control out into text.
DOCUMENTED_CONTROLS = [
  "Within this list",
  "Among all lists"
].freeze

Check.register(
  id: "no-instruction-only-in-image",
  desc: "Every documented control name appears in real page text, not only inside an image's alt attribute or filename",
  covers: ["6.5"]
) do |site|
  offenders = DOCUMENTED_CONTROLS.reject do |control|
    site.pages.any? do |page|
      text_only = page.body.gsub(/<img\b[^>]*>/i, "")
      text_only.include?(control)
    end
  end

  unless offenders.empty?
    site.fail!("control name(s) not documented as real text anywhere: #{offenders.join(', ')}")
  end
end
