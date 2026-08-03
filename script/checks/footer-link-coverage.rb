# frozen_string_literal: true

# Story 5.10: secondary/administrivia pages opt out of the sidebar via
# nav_exclude: true but must stay reachable from every page's footer. A page
# with its own custom permalink (404.md) is a reserved error route, not
# content the footer needs to surface, so it's exempt.
Check.register(
  id: "footer-link-coverage",
  desc: "Every nav_exclude: true page without a custom permalink is linked from the footer, and every built page renders the footer",
  covers: ["5.10"]
) do |site|
  page_url = lambda do |path|
    rel = path.sub(/\.md\z/, "").sub(%r{/index\z}, "").sub(/\Aindex\z/, "")
    rel.empty? ? "/" : "/#{rel}/"
  end

  # The per-href sweep below is the assertion's real subject: with no secondary
  # page to look for, its loop body never runs and the built pages it would
  # have read go unexamined, while the accessors above still report every page.
  secondary_hrefs = site.examining(
    "footer-linked secondary pages",
    site.pages.select { |p| p.front_matter["nav_exclude"] == true && p.front_matter["permalink"].nil? }
  ).map { |p| page_url.call(p.path) }

  missing_footer = site.html_files.reject { |f| f.body.include?('class="footer-secondary-links"') }
  unless missing_footer.empty?
    site.fail!("built page(s) missing the footer: #{missing_footer.map(&:path).join(', ')}")
  end

  secondary_hrefs.each do |href|
    missing = site.html_files.reject { |f| f.body.include?(%(href="#{href}")) }
    unless missing.empty?
      site.fail!("#{missing.size} built page(s) missing a footer link to #{href}, e.g. #{missing.first.path}")
    end
  end
end
