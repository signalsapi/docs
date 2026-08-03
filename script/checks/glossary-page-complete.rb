# frozen_string_literal: true

# Every term has to be found in the glossary page's own content, because that
# is the claim — one definition per term, on this page. Searching the whole
# built body let just-the-docs' chrome answer instead: Signal, Search, Filter
# and Persona are all nav or search labels rendered into every page, so
# deleting any of those four entries from the glossary left this green
# (signalsapi-4328). Those four are also the shortest and most reusable terms
# here, which is to say the exemption grows with the site rather than shrinking.
#
# Same class as affiliate-disclosure-linked (signalsapi-4324) and
# no-instruction-only-in-image (signalsapi-4327); the content region comes from
# the Site model for the same reason it does there.
Check.register(
  id: "glossary-page-complete",
  desc: "The built /concepts/glossary/ page's own content contains every entry present in _data/glossary.yml",
  covers: ["4.4"]
) do |site|
  path = "_site/concepts/glossary/index.html"

  page = site.content_pages.find { |f| f.path == path }
  site.fail!("#{path} is missing") unless page

  # One page is the subject, not the 58 content regions the accessor builds.
  site.examining("the built glossary page", [page])

  missing = site.data["glossary"]["items"].map { |e| e["term"] }.reject { |term| page.body.include?(term) }
  site.fail!("glossary page is missing entry/entries: #{missing.join(', ')}") unless missing.empty?
end
