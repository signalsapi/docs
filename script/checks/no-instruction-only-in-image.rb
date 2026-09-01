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
#
# "Within this list" and "Among all lists" were removed from this list because
# they were removed from the site, and they were removed from the site because
# the product has no such controls. They came from the Story 11.3 screenshots
# of an older settings panel; nothing behind them was ever shipped, so pinning
# them here was holding a promise open on the strength of a picture. The one
# control that does exist on that subject — "Signals per company per day" —
# takes their place.
#
# "Real text" has to mean the same thing on both sides of that disjunction, and
# for a while it did not (signalsapi-4327): the source half stripped <img …>
# tags before searching, while the built half searched each page's whole
# rendered HTML. So a control name written only into an alt attribute passed —
# the one thing this assertion exists to forbid — and so did one appearing
# anywhere in the chrome just-the-docs renders into every page, which satisfied
# the check for the whole site at once. Both halves now strip images and read
# page content only; the built side gets its content region from the Site model
# (site.content_pages), which is where affiliate-disclosure-linked gets the same
# thing after the same defect (signalsapi-4324).
IMG_TAG_RE = /<img\b[^>]*>/i.freeze

DOCUMENTED_CONTROLS = [
  "Signals per company per day",
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
    documented = lambda do |body|
      body.gsub(IMG_TAG_RE, "").include?(control)
    end

    site.pages.any? { |page| documented.call(page.body) } ||
      site.content_pages.any? { |page| documented.call(page.body) }
  end

  unless offenders.empty?
    site.fail!("control name(s) not documented as real text anywhere: #{offenders.join(', ')}")
  end
end
