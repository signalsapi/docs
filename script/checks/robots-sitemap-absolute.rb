# frozen_string_literal: true

Check.register(
  id: "robots-sitemap-absolute",
  desc: "_site/robots.txt exists with an absolute Sitemap: line and no double slash after the host",
  covers: ["2.5"]
) do |site|
  site.fail!("_site/robots.txt is missing") unless site.exist?("_site/robots.txt")

  content = site.raw("_site/robots.txt")
  sitemap_line = content.lines.find { |l| l.start_with?("Sitemap:") }
  site.fail!("_site/robots.txt has no Sitemap: line") unless sitemap_line

  url = sitemap_line.sub("Sitemap:", "").strip
  site.fail!("_site/robots.txt's Sitemap: line must be an absolute URL") unless url.start_with?("http://", "https://")

  if url.sub(%r{\Ahttps?://}, "").include?("//")
    site.fail!("_site/robots.txt's Sitemap: line contains a double slash after the host")
  end
end
