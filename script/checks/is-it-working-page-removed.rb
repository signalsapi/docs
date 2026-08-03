# frozen_string_literal: true

# Story 11.11 retires is-it-working.md, a 23-word page that duplicated the
# FAQ's own "Is it working?" answer verbatim. This pins down the specific
# cleanup the story requires — the file is gone, the FAQ claims both of its
# old URLs, and no changelog entry still points at the deleted page — as a
# narrow complement to the generic no-page-deleted-without-redirect check.
Check.register(
  id: "is-it-working-page-removed",
  desc: "is-it-working.md is gone and the FAQ claims its redirects and changelog entry",
  covers: ["11.11"]
) do |site|
  if File.exist?(File.join(ROOT, "is-it-working.md"))
    site.fail!("is-it-working.md still exists — it duplicates the FAQ's \"Is it working?\" answer")
  end

  faq = site.pages.find { |p| p.path == "faq.md" }
  site.fail!("faq.md is missing") unless faq

  faq_redirects = Array(faq.front_matter["redirect_from"])
  missing = %w[/is-it-working.html /is-it-working/].reject { |url| faq_redirects.include?(url) }
  unless missing.empty?
    site.fail!("faq.md's redirect_from is missing #{missing.join(', ')} — the retired page's old URL(s) are orphaned")
  end

  stale = (site.data.dig("changelog", "items") || []).select { |i| i["feature"] == "is-it-working.md" }
  unless stale.empty?
    site.fail!("_data/changelog.yml still has #{stale.size} entr(y/ies) targeting the deleted is-it-working.md")
  end
end
