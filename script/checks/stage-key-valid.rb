# frozen_string_literal: true

Check.register(
  id: "stage-key-valid",
  desc: "Every page's stage: front-matter value names a stage declared in _data/pipeline.yml",
  covers: ["4.8"]
) do |site|
  valid_keys = site.data["pipeline"].map { |s| s["key"] }

  offenders = site.pages
                  .select { |p| p.front_matter.key?("stage") }
                  .reject { |p| valid_keys.include?(p.front_matter["stage"]) }

  unless offenders.empty?
    details = offenders.map { |p| "#{p.path}: #{p.front_matter['stage'].inspect}" }.join(", ")
    site.fail!("stage: value not declared in _data/pipeline.yml — #{details}")
  end
end
