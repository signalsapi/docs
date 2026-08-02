# frozen_string_literal: true

# parent: resolves by matching a page's title:, so two pages sharing a
# title would make any `parent: <that title>` ambiguous about which
# section a child actually nests under.
Check.register(
  id: "title-unique",
  desc: "No two pages declare the same title",
  covers: ["5.9"]
) do |site|
  duplicates = site.pages
                    .group_by { |p| p.front_matter["title"] }
                    .select { |title, pages| title && pages.size > 1 }

  unless duplicates.empty?
    details = duplicates.map { |title, pages| "#{title.inspect} used by #{pages.map(&:path).join(', ')}" }
                         .join("; ")
    site.fail!("duplicate title(s) — #{details}")
  end
end
