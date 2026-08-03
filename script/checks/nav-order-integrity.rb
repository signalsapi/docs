# frozen_string_literal: true

Check.register(
  id: "nav-order-integrity",
  desc: "Every sibling group of pages (by parent) has unique, integer, contiguous nav_order values",
  covers: ["2.10"]
) do |site|
  groups = site.examining(
    "navigable pages declaring a nav_order",
    site.pages.reject { |p| p.front_matter["nav_exclude"] }.select { |p| !p.front_matter["nav_order"].nil? }
  ).group_by { |p| p.front_matter["parent"] }

  groups.each do |parent, pages|
    label = parent.nil? ? "top-level pages" : "children of #{parent}"
    orders = pages.map { |p| p.front_matter["nav_order"] }

    non_integers = orders.reject { |o| o.is_a?(Integer) }
    site.fail!("#{label}: non-integer nav_order value(s): #{non_integers.join(', ')}") unless non_integers.empty?

    duplicates = orders.tally.select { |_, count| count > 1 }.keys
    site.fail!("#{label}: duplicate nav_order value(s): #{duplicates.join(', ')}") unless duplicates.empty?

    sorted = orders.sort
    expected = (sorted.first..sorted.last).to_a
    site.fail!("#{label}: nav_order sequence has a gap — got #{sorted.join(', ')}") if sorted != expected
  end
end
