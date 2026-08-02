# frozen_string_literal: true

# Story 8.9: each surface already asserts its own completeness against
# site.pages (sitemap-covers-published-pages, llms-txt-covers-pages,
# llms-full-covers-pages) — this instead cross-checks the surfaces against
# EACH OTHER, so a bug shared between a generator and its own self-check
# (both silently agreeing on the wrong page set) still surfaces here.
Check.register(
  id: "machine-surfaces-in-sync",
  desc: "sitemap.xml, robots.txt, llms.txt and llms-full.txt all exist and reference the same page set",
  covers: ["8.9"]
) do |site|
  paths = {
    "sitemap.xml" => File.join(ROOT, "_site", "sitemap.xml"),
    "robots.txt" => File.join(ROOT, "_site", "robots.txt"),
    "llms.txt" => File.join(ROOT, "_site", "llms.txt"),
    "llms-full.txt" => File.join(ROOT, "_site", "llms-full.txt")
  }

  paths.each { |name, path| site.fail!("_site/#{name} is missing") unless File.exist?(path) }

  sitemap_urls = File.read(paths["sitemap.xml"]).scan(%r{<loc>(.*?)</loc>}).flatten.uniq
  llms_txt_urls = File.read(paths["llms.txt"]).scan(%r{https?://\S+}).uniq
  llms_full_urls = File.read(paths["llms-full.txt"]).scan(%r{https?://\S+}).uniq

  missing_from_llms_txt = sitemap_urls - llms_txt_urls
  missing_from_llms_full = llms_txt_urls - llms_full_urls

  offenders = []
  unless missing_from_llms_txt.empty?
    offenders << "in sitemap.xml but not llms.txt: #{missing_from_llms_txt.join(', ')}"
  end
  unless missing_from_llms_full.empty?
    offenders << "in llms.txt but not llms-full.txt: #{missing_from_llms_full.join(', ')}"
  end

  site.fail!("machine-readable surfaces out of sync — #{offenders.join('; ')}") unless offenders.empty?
end
