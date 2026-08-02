# frozen_string_literal: true

# AD-7/NFR3: a price lives in _data/pricing.yml, not in prose, so two pages
# cannot disagree about what something costs. Matches a currency symbol
# immediately followed by a digit, so illustrative examples that merely
# contain the glyph (a job-posting salary placeholder, say) don't trip it.
Check.register(
  id: "currency-outside-data",
  desc: "No .md file outside _data/pricing.yml and the pricing page template states a bare currency figure",
  covers: ["2.9"]
) do |site|
  offenders = site.pages.select { |p| site.raw(p.path) =~ /[£$€]\s?\d/ }

  unless offenders.empty?
    site.fail!("currency figure found outside _data/pricing.yml in: #{offenders.map(&:path).join(', ')}")
  end
end
