# frozen_string_literal: true

Check.register(
  id: "router-page-shape",
  desc: "Every page_type: router page has a '## Where to go' heading, at least three internal links, no image, and fewer than 250 words",
  covers: ["4.6"]
) do |site|
  offenders = []

  site.pages.select { |p| p.front_matter["page_type"] == "router" }.each do |page|
    problems = []
    problems << "missing a '## Where to go' heading" unless page.body.include?("## Where to go")

    internal_links = page.body.scan(/\]\((\/[^)]*)\)/).flatten.uniq
    problems << "has #{internal_links.size} internal link(s), fewer than the required three" if internal_links.size < 3

    if page.body.match?(/!\[[^\]]*\]\(/) || page.body.match?(/<img\b/i)
      problems << "contains an image"
    end

    word_count = page.body.split(/\s+/).reject(&:empty?).size
    problems << "has #{word_count} word(s), not fewer than 250" if word_count >= 250

    offenders << "#{page.path}: #{problems.join(', ')}" unless problems.empty?
  end

  site.fail!("router page shape violation(s) — #{offenders.join('; ')}") unless offenders.empty?
end
