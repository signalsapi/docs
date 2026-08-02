# frozen_string_literal: true

# Derives each page's pretty-permalink URL (/:path/, with a trailing "index"
# segment dropped) rather than reading it off the built HTML, since that's
# the one thing jekyll-sitemap and Jekyll's own router are both computing
# from the same source path.
Check.register(
  id: "sitemap-covers-published-pages",
  desc: "sitemap.xml lists every page that is not nav_exclude'd and not sitemap: false",
  covers: ["2.4"]
) do |site|
  sitemap_path = File.join(ROOT, "_site", "sitemap.xml")
  site.fail!("_site/sitemap.xml is missing") unless File.exist?(sitemap_path)

  sitemap_urls = File.read(sitemap_path).scan(%r{<loc>(.*?)</loc>}).flatten

  missing = site.pages.filter_map do |page|
    next if page.front_matter["nav_exclude"] || page.front_matter["sitemap"] == false

    slug = page.path.sub(/\.md\z/, "").sub(%r{(^|/)index\z}, '\1').chomp("/")
    url = slug.empty? ? "https://docs.signalsapi.com/" : "https://docs.signalsapi.com/#{slug}/"

    page.path unless sitemap_urls.include?(url)
  end

  site.fail!("sitemap.xml is missing published page(s): #{missing.join(', ')}") unless missing.empty?
end
