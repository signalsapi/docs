# frozen_string_literal: true

# Story 8.2: jekyll-seo-tag renders these three tags once per page via the
# theme's head.html; a duplicate (e.g. a hand-added canonical) or a missing
# one both break how a crawler resolves the page's real address.
Check.register(
  id: "one-canonical-per-page",
  desc: "Every built page carries exactly one canonical link, one og:title and one og:url, with no double slash after the host",
  covers: %w[2.14 8.2]
) do |site|
  offenders = []

  site.html_files.each do |file|
    canonicals = file.body.scan(/<link\s+rel="canonical"\s+href="([^"]*)"/).flatten
    og_titles = file.body.scan(/<meta\s+property="og:title"\s+content="([^"]*)"/).flatten
    og_urls = file.body.scan(/<meta\s+property="og:url"\s+content="([^"]*)"/).flatten

    offenders << "#{file.path}: #{canonicals.size} canonical link(s)" unless canonicals.size == 1
    offenders << "#{file.path}: #{og_titles.size} og:title tag(s)" unless og_titles.size == 1
    offenders << "#{file.path}: #{og_urls.size} og:url tag(s)" unless og_urls.size == 1

    (canonicals + og_urls).each do |url|
      if url.sub(%r{\Ahttps?://}, "").include?("//")
        offenders << "#{file.path}: double slash after host in #{url}"
      end
    end
  end

  site.fail!("canonical/og metadata violation(s) — #{offenders.join('; ')}") unless offenders.empty?
end
