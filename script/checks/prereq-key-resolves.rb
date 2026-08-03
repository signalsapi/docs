# frozen_string_literal: true

Check.register(
  id: "prereq-key-resolves",
  desc: "Every page's prereq: value names an entry declared in _data/prereqs.yml",
  covers: ["7.8"]
) do |site|
  site.fail!("_data/prereqs.yml is missing") unless site.data["prereqs"]

  valid_keys = site.data["prereqs"]["items"].map { |p| p["key"] }

  offenders = site.examining("pages declaring a prereq", site.pages.select { |p| p.front_matter.key?("prereq") })
                  .reject { |p| valid_keys.include?(p.front_matter["prereq"]) }

  unless offenders.empty?
    details = offenders.map { |p| "#{p.path}: #{p.front_matter['prereq'].inspect}" }.join(", ")
    site.fail!("prereq: value not declared in _data/prereqs.yml — #{details}")
  end
end
