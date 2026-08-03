# frozen_string_literal: true

Check.register(
  id: "description-unique",
  desc: "No two pages declare the same description",
  covers: ["5.3"]
) do |site|
  duplicates = site.pages
                    .group_by { |p| p.front_matter["description"] }
                    .select { |description, pages| description && pages.size > 1 }

  unless duplicates.empty?
    details = duplicates.map { |description, pages| "#{description.inspect} used by #{pages.map(&:path).join(', ')}" }
                         .join("; ")
    site.fail!("duplicate description(s) — #{details}")
  end
end
