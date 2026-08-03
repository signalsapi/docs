# frozen_string_literal: true

Check.register(
  id: "llms-txt-covers-pages",
  desc: "_site/llms.txt lists every published page's absolute URL, with no double slash after the host",
  covers: ["8.3"]
) do |site|
  site.fail!("_site/llms.txt is missing") unless site.exist?("_site/llms.txt")

  content = site.raw("_site/llms.txt")
  base_url = YAML.safe_load(site.raw("_config.yml"))["url"]

  urls = content.scan(%r{https?://\S+})
  double_slash = urls.select { |u| u.sub(%r{\Ahttps?://}, "").include?("//") }
  unless double_slash.empty?
    site.fail!("_site/llms.txt has URL(s) with a double slash after the host — #{double_slash.uniq.join(', ')}")
  end

  # Jekyll's site-wide `permalink: pretty` turns a page's path into
  # /dir/name/ (or / for an index), unless the page overrides permalink
  # itself (404.md does) — mirror that here rather than rendering the site.
  missing = site.pages.select { |p| p.front_matter["page_type"] }.reject do |p|
    rel = p.front_matter["permalink"] || begin
      stripped = p.path.sub(/\.md\z/, "").sub(%r{(\A|/)index\z}, "")
      stripped.empty? ? "/" : "/#{stripped}/"
    end
    content.include?("#{base_url}#{rel}")
  end

  site.fail!("page(s) absent from _site/llms.txt — #{missing.map(&:path).join(', ')}") unless missing.empty?
end
