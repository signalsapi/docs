# frozen_string_literal: true

Check.register(
  id: "home-is-router",
  desc: "index.md links to no booking host, carries at least six internal links, and stays under the router word budget",
  covers: ["5.1"]
) do |site|
  page = site.pages.find { |p| p.path == "index.md" }
  site.fail!("index.md is missing") unless page

  site.fail!("index.md links to the booking host") if page.body.include?("fillout.com")

  internal_links = page.body.scan(/\]\((\/[^)]*)\)/).flatten.uniq
  if internal_links.size < 6
    site.fail!("index.md has #{internal_links.size} internal link(s), fewer than the required six")
  end

  word_count = page.body.split(/\s+/).reject(&:empty?).size
  site.fail!("index.md has #{word_count} word(s), not fewer than 250") if word_count >= 250
end
