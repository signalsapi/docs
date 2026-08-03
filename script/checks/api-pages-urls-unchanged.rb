# frozen_string_literal: true

# Story 10.10 re-parents five pages under the new APIs router without moving
# their files — just-the-docs resolves parent: by title, so a page's own URL
# never depends on it. _data/api_pages_baseline.yml (not _data/baseline.yml,
# whose items: are a separately-guarded historical snapshot per Story 3.3)
# records what each page's URL was expected to be; this proves it still is,
# both in the front matter and in the actual built output.
Check.register(
  id: "api-pages-urls-unchanged",
  desc: "each of the five interface pages' built URL matches its recorded baseline",
  covers: ["10.10"]
) do |site|
  baseline = site.data["api_pages_baseline"]
  site.fail!("_data/api_pages_baseline.yml is missing") unless baseline

  mismatches = baseline["items"].filter_map do |item|
    page = site.pages.find { |p| p.path == item["path"] }
    next "#{item['path']}: page no longer exists" unless page

    actual_url = page.front_matter["permalink"] || "/#{page.path.sub(/\.md\z/, '').sub(%r{/index\z}, '')}/"
    next "#{item['path']}: URL is now #{actual_url}, baseline recorded #{item['url']}" if actual_url != item["url"]

    built_path = File.join(ROOT, "_site", actual_url, "index.html")
    next "#{item['path']}: #{actual_url} does not resolve to a built file" unless File.exist?(built_path)

    nil
  end

  site.fail!("interface page URL drift — #{mismatches.join('; ')}") unless mismatches.empty?
end
