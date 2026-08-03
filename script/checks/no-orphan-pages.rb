# frozen_string_literal: true

# Distinct from orphan-pages-reported (9.3, the health-page dashboard
# metric): this is the actual gate, and it excludes nav_excluded utility
# pages (404, support, tos, ...) that are legitimately reached only via
# the footer, not from prose.
Check.register(
  id: "no-orphan-pages",
  desc: "Every published page that is not a router and not nav_excluded has at least one inbound in-body link",
  covers: ["9.5"]
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
                       .reject { |p| p.front_matter["nav_exclude"] == true }
                       .select { |p| inbound[page_url.call(p)].zero? }

  unless orphans.empty?
    details = orphans.map { |p| "#{p.path} (section: #{p.front_matter['parent'] || 'top-level'})" }.join(", ")
    site.fail!("orphan page(s) with zero inbound in-body links — #{details}")
  end
end
