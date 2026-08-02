# frozen_string_literal: true

Check.register(
  id: "search-creation-documented",
  desc: "Some page in the built site declares the pipeline's first stage as its stage: value",
  covers: ["5.7"]
) do |site|
  first_stage = site.data["pipeline"]["items"].first["key"]

  documented = site.pages.any? { |p| p.front_matter["stage"] == first_stage }

  site.fail!("no page declares stage: #{first_stage} (the pipeline's first stage)") unless documented
end
