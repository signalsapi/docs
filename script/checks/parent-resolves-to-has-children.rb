# frozen_string_literal: true

Check.register(
  id: "parent-resolves-to-has-children",
  desc: "Every page's parent: value matches the title of a page declaring has_children: true",
  covers: ["4.9"]
) do |site|
  section_titles = site.pages
                        .select { |p| p.front_matter["has_children"] == true }
                        .map { |p| p.front_matter["title"] }

  offenders = site.pages
                  .select { |p| p.front_matter["parent"] }
                  .reject { |p| section_titles.include?(p.front_matter["parent"]) }

  unless offenders.empty?
    details = offenders.map { |p| "#{p.path}: parent #{p.front_matter['parent'].inspect}" }.join(", ")
    site.fail!("parent: value doesn't resolve to a has_children: true page — #{details}")
  end
end
