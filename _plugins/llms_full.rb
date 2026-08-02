# frozen_string_literal: true

# Story 8.4: llms-full.txt must be genuine pre-conversion Markdown, not
# Jekyll's rendered HTML. Reading page.content here would race Jekyll's own
# render order — pages later in site.pages are still raw markdown at the
# point this page renders, pages earlier are already converted to HTML.
# Reading every file straight off disk sidesteps that race entirely.
Jekyll::Hooks.register :pages, :pre_render do |page|
  next unless page.data["permalink"] == "/llms-full.txt"

  site = page.site
  base_url = site.config["url"]

  content_pages = site.pages
                       .select { |p| p.data["page_type"] }
                       .sort_by { |p| p.data["title"].to_s }

  page.content = content_pages.map do |p|
    raw = File.read(site.in_source_dir(p.relative_path))
    _, _, body = raw.split(/^---\s*$/, 3)
    "# #{p.data['title']}\n#{base_url}#{p.url}\n\n#{body.to_s.strip}\n"
  end.join("\n---\n\n")
end
