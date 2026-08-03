# frozen_string_literal: true

# _data/pricing.yml holds the ladder twice: once as four plan_tier rows the
# table renders from, and once as the one-sentence pull quote answer engines
# actually quote (that duplication is deliberate — signalsapi-4208 was caused
# by a non-canonical figure being the quotable one). This is the guard that
# keeps the two in step: every per-month figure in the rows has to appear in
# the summary, so editing a plan price without editing the sentence reds.
Check.register(
  id: "pricing-ladder-summary-matches-rows",
  desc: "Every plan_tier figure in _data/pricing.yml appears in the self_serve_ladder_summary pull quote",
  covers: ["7.7"]
) do |site|
  items = site.data.dig("pricing", "items") || []
  summary = items.find { |i| i["name"] == "self_serve_ladder_summary" }
  site.fail!("_data/pricing.yml has no self_serve_ladder_summary item") unless summary

  tiers = items.select { |i| i["kind"] == "plan_tier" }
  site.fail!("_data/pricing.yml declares no plan_tier rows") if tiers.empty?

  missing = tiers.reject do |tier|
    summary["value"].include?(tier["value"].to_s) && summary["value"].include?(tier["included"].to_s)
  end

  unless missing.empty?
    details = missing.map { |t| "#{t['label']} (#{t['value']} / #{t['included']})" }.join(", ")
    site.fail!("plan tier(s) absent from the ladder summary: #{details}")
  end
end
