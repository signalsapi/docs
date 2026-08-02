# frozen_string_literal: true

# The information architecture fixes the top-level section count at this
# value. A top-level section is a page with an integer nav_order and no
# parent:. Adding or retiring one must update this constant in the same
# commit — the tree can grow, but it cannot grow silently.
ROOT_SECTION_COUNT = 10

Check.register(
  id: "root-section-count",
  desc: "The number of top-level pages (integer nav_order, no parent:) matches the constant declared in this file",
  covers: ["5.9"]
) do |site|
  top_level = site.pages.select do |p|
    p.front_matter["nav_order"].is_a?(Integer) && p.front_matter["parent"].nil?
  end

  if top_level.size != ROOT_SECTION_COUNT
    site.fail!("expected #{ROOT_SECTION_COUNT} top-level page(s), found #{top_level.size}: " \
               "#{top_level.map(&:path).join(', ')}")
  end
end
