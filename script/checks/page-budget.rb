# frozen_string_literal: true

# Story 11.12: adding a hand-written page should be a deliberate act, not
# something the corpus accretes unnoticed. _data/baseline.yml pins a live
# ceiling (hand_written_pages_ceiling) alongside its historical items —
# raising it takes a commit that also bumps meta.verified_on, the same
# "changed without also touching verified_on" gate baseline-immutable
# (Story 3.3) already enforces on the rest of that file.
Check.register(
  id: "page-budget",
  desc: "the hand-written page count never exceeds _data/baseline.yml's pinned ceiling without the ceiling changing in the same commit",
  covers: ["11.12"]
) do |site|
  ceiling = site.data.dig("baseline", "items", "hand_written_pages_ceiling")
  site.fail!("_data/baseline.yml is missing items.hand_written_pages_ceiling") unless ceiling.is_a?(Integer)

  count = site.pages.size
  next if count <= ceiling

  committed_text = `git -C #{ROOT} show HEAD:_data/baseline.yml 2>/dev/null`
  committed_ceiling = if $?.success?
                        YAML.safe_load(committed_text, permitted_classes: [Date]).dig("items", "hand_written_pages_ceiling")
                      end

  if committed_ceiling == ceiling
    site.fail!(
      "page-budget: #{count} hand-written pages exceeds the pinned ceiling of #{ceiling} — raise " \
      "items.hand_written_pages_ceiling in _data/baseline.yml (bumping meta.verified_on in the same " \
      "commit) and record the retirement-ledger entry that justifies the new page"
    )
  end
end
