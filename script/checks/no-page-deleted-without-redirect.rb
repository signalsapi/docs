# frozen_string_literal: true

# Story 8.8 / NFR5: ddc51a8 is the last real-content commit before this
# overhaul began (the same commit _data/baseline.yml is measured from).
# README.md was a leaked, unedited theme template (audit finding #7) —
# never real content, and already excluded from the built site today, so
# it isn't part of the "page" surface this assertion protects.
BASELINE_COMMIT = "ddc51a8"

Check.register(
  id: "no-page-deleted-without-redirect",
  desc: "Every page from the pre-overhaul baseline still resolves, live or via redirect_from",
  covers: ["8.8"]
) do |site|
  baseline_files = `git -C #{ROOT} ls-tree -r --name-only #{BASELINE_COMMIT}`
                   .lines.map(&:strip).select { |f| f.end_with?(".md") } - ["README.md"]
  site.fail!("git ls-tree of #{BASELINE_COMMIT} returned no markdown files") if baseline_files.empty?

  baseline_url = lambda do |path|
    dir = File.dirname(path)
    basename = File.basename(path, ".md")
    if basename == "index"
      dir == "." ? "/" : "/#{dir}/"
    else
      dir == "." ? "/#{basename}.html" : "/#{dir}/#{basename}.html"
    end
  end

  current_url = lambda do |page|
    next page.front_matter["permalink"] if page.front_matter["permalink"]

    stripped = page.path.sub(/\.md\z/, "").sub(%r{(\A|/)index\z}, "")
    stripped.empty? ? "/" : "/#{stripped}/"
  end

  live_urls = site.pages.map { |p| current_url.call(p) }
  redirected_urls = site.pages.flat_map { |p| Array(p.front_matter["redirect_from"]) }
  known_urls = live_urls + redirected_urls

  orphaned = baseline_files.reject { |f| known_urls.include?(baseline_url.call(f)) }

  unless orphaned.empty?
    details = orphaned.map { |f| "#{f} (was #{baseline_url.call(f)})" }.join(", ")
    site.fail!("baseline page(s) with neither a live URL nor a redirect_from entry — #{details}")
  end
end
