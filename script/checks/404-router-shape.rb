# frozen_string_literal: true

# Story 2.6 bought two different things, and reading them the same way is what
# left one of them unable to fail. The commit that added the page (85fea8c)
# separates them itself: the layout "renders the theme's standard header and
# sidebar - including the lunr search input - for free, plus six explicit links
# to top-level destinations".
#
# The search input is therefore chrome on purpose, and the whole built page is
# the right place to look for it — what is being pinned is that 404.html keeps
# getting it, which stops holding the day the page moves off a header-rendering
# layout or the theme's search is switched off in _config.yml.
#
# The six links are the page's own words, and those were being counted in the
# whole built body too. just-the-docs renders 57 internal links into every
# page's nav, so a floor of six was cleared nine times over before 404.md said
# anything at all: emptying the bullet list entirely left this green
# (signalsapi-4328). They are counted in the page's own content region now.
#
# Third of the same class, after affiliate-disclosure-linked (signalsapi-4324)
# and no-instruction-only-in-image (signalsapi-4327), which is why the region
# comes from the Site model rather than from a regexp of this check's own.
Check.register(
  id: "404-router-shape",
  desc: "_site/404.html exists, renders the theme's search input, and carries at least six internal links in its own content",
  covers: ["2.6"]
) do |site|
  path = "_site/404.html"

  built = site.html_files.find { |f| f.path == path }
  site.fail!("#{path} is missing") unless built

  # One page is the subject, not the 58 the accessors above hand over.
  site.examining("the built 404 page", [built])

  unless built.body.include?("search-input")
    site.fail!("#{path} does not render the search input its layout is supposed to give it")
  end

  content = site.content_pages.find { |f| f.path == path }
  internal_links = content.body.scan(/<a\s[^>]*href="(\/[^"]*)"/).flatten.uniq
  if internal_links.size < 6
    site.fail!("#{path} offers #{internal_links.size} internal link(s) of its own, " \
               "fewer than the required six")
  end
end
