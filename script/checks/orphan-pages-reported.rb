# frozen_string_literal: true

# Reported, not failed — a page reachable only from the nav sidebar and
# never from another page's prose is a content gap worth seeing, not a
# build-blocking defect.
Check.register(
  id: "orphan-pages-reported",
  desc: "Pages with zero inbound in-body links are reported so the health page reflects real content",
  covers: ["9.3"]
) do |site|
  page_url = lambda do |page|
    page.front_matter["permalink"] || begin
      stripped = page.path.sub(/\.md\z/, "").sub(%r{(\A|/)index\z}, "")
      stripped.empty? ? "/" : "/#{stripped}/"
    end
  end

  resolve = lambda do |link, from_url|
    target = link.split("#").first
    resolved = File.expand_path(target, from_url)
    resolved += "/" unless resolved.include?(".") || resolved.end_with?("/")
    resolved
  end

  inbound = Hash.new(0)
  site.pages.each do |page|
    from_url = page_url.call(page)
    page.body.scan(/(?<!!)\[[^\]]*\]\(((?:\.\.\/|\/)[^)]*)\)/).flatten.each do |link|
      inbound[resolve.call(link, from_url)] += 1
    end
  end

  orphans = site.pages.reject { |p| p.front_matter["page_type"] == "router" }
                       .select { |p| inbound[page_url.call(p)].zero? }
                       .map(&:path)

  unless orphans.empty?
    puts "orphan-pages-reported: #{orphans.size} page(s) with zero inbound in-body links:"
    orphans.each { |o| puts "  - #{o}" }
  end
end
