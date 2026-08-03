# frozen_string_literal: true

# The baseline is a historical record, not a moving target: items: may only
# change in a commit that also updates meta.verified_on, so nobody can
# quietly improve the past. Compares the working tree against the last
# commit; if that commit predates the meta:/items: envelope (or this is the
# very first commit introducing it), there is nothing yet to compare.
#
# hand_written_pages_ceiling (Story 11.12) is excluded from this
# comparison: it's a live page-budget ceiling, not a historical
# measurement, and can legitimately move more than once on the same
# calendar day (verified_on has day granularity). page-budget.rb already
# guards it directly against git HEAD.
Check.register(
  id: "baseline-immutable",
  desc: "_data/baseline.yml's items: don't change without meta.verified_on changing in the same commit",
  covers: ["3.3"]
) do |site|
  current = YAML.safe_load(site.raw("_data/baseline.yml"), permitted_classes: [Date])

  committed_text = `git -C #{ROOT} show HEAD:_data/baseline.yml 2>/dev/null`
  next unless $?.success?

  committed = YAML.safe_load(committed_text, permitted_classes: [Date])
  next unless committed.is_a?(Hash) && committed.key?("items") && committed.key?("meta")

  historical = ->(items) { items.reject { |k, _| k == "hand_written_pages_ceiling" } }

  same_items = historical.call(current["items"]) == historical.call(committed["items"])
  same_verified_on = current.dig("meta", "verified_on") == committed.dig("meta", "verified_on")

  if !same_items && same_verified_on
    site.fail!("_data/baseline.yml's items: changed without meta.verified_on changing in the same commit")
  end
end
