# frozen_string_literal: true

require "set"

# Reported, not failed — html-proofer's own check:links stage already gates
# broken links (a real one would already fail the build before this runs).
# This is an independent, native re-derivation for the health page, so a
# gap in html-proofer's own resolution wouldn't silently agree with itself.
Check.register(
  id: "docs-health-links-resolve",
  desc: "Every internal markdown link resolves to a known page URL",
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

  known_urls = site.pages.map { |p| page_url.call(p) }.to_set

  offenders = site.pages.flat_map do |page|
    from_url = page_url.call(page)
    page.body.scan(/(?<!!)\[[^\]]*\]\(((?:\.\.\/|\/)[^)]*)\)/).flatten.uniq.filter_map do |link|
      target = resolve.call(link, from_url)
      "#{page.path}: #{link}" unless known_urls.include?(target)
    end
  end

  unless offenders.empty?
    puts "docs-health-links-resolve: #{offenders.size} internal link(s) that don't resolve:"
    offenders.each { |o| puts "  - #{o}" }
  end
end
