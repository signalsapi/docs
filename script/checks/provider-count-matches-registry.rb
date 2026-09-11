# frozen_string_literal: true

# signalsapi-5126: the comparison page spells out how many providers it
# compares, in its description and in its opening paragraph. Two providers
# shipped without that word changing, so the page promised to compare "all
# eleven" of thirteen. The tables are loops over _data/providers.yml and
# stayed right; the hand-typed number is what drifted, so it is checked here.
PROVIDER_COUNT_PAGE = "features/compare-people-data-providers.md"
PROVIDER_COUNT_WORDS = %w[
  zero one two three four five six seven eight nine ten eleven twelve thirteen
  fourteen fifteen sixteen seventeen eighteen nineteen twenty
].freeze

Check.register(
  id: "provider-count-matches-registry",
  desc: "The provider count the comparison page states in words matches the number of _data/providers.yml items",
  covers: ["7.2"]
) do |site|
  site.fail!("_data/providers.yml is missing") unless site.data["providers"]

  count = site.data["providers"]["items"].size
  expected = PROVIDER_COUNT_WORDS.fetch(count) { count.to_s }
  number = "(#{PROVIDER_COUNT_WORDS.join('|')}|\\d+)"

  # "all eleven" in the body, "the eleven supported people-data providers" in
  # the description. Other number words on the page ("the three that do both
  # at source") count a subset and are deliberately not matched.
  raw = site.raw(PROVIDER_COUNT_PAGE)
  stated = raw.scan(/\ball #{number}\b/i).flatten +
           raw.scan(/\b#{number} supported people-data providers\b/i).flatten
  site.fail!("#{PROVIDER_COUNT_PAGE} no longer states a provider count this check can find") if stated.empty?

  wrong = stated.map(&:downcase).reject { |word| word == expected }
  unless wrong.empty?
    site.fail!("#{PROVIDER_COUNT_PAGE} says #{wrong.uniq.join(', ')} providers, but _data/providers.yml has #{count} (#{expected})")
  end
end
