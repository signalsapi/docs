# frozen_string_literal: true

Check.register(
  id: "404-router-shape",
  desc: "_site/404.html exists, references the search input, and links to at least six internal destinations",
  covers: ["2.6"]
) do |site|
  page = site.html_files.find { |f| f.path == "_site/404.html" }
  site.fail!("_site/404.html is missing") unless page

  body = page.body
  site.fail!("_site/404.html does not reference the search input") unless body.include?("search-input")

  internal_links = body.scan(/<a\s[^>]*href="(\/[^"]*)"/).flatten.uniq
  if internal_links.size < 6
    site.fail!("_site/404.html has #{internal_links.size} internal link(s), fewer than the required six")
  end
end
