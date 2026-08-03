# frozen_string_literal: true

Check.register(
  id: "no-childless-has-children",
  desc: "Every page declaring has_children: true is named as a parent: by at least one other page",
  covers: ["5.8"]
) do |site|
  section_titles = site.examining("section pages", site.pages.select { |p| p.front_matter["has_children"] == true })
                       .map { |p| p.front_matter["title"] }

  parent_values = site.pages.map { |p| p.front_matter["parent"] }.compact.uniq

  offenders = section_titles.reject { |title| parent_values.include?(title) }

  site.fail!("has_children: true page(s) with no matching parent: — #{offenders.join(', ')}") unless offenders.empty?
end
