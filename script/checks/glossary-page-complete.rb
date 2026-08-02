# frozen_string_literal: true

Check.register(
  id: "glossary-page-complete",
  desc: "The built /concepts/glossary/ page contains every entry present in _data/glossary.yml",
  covers: ["4.4"]
) do |site|
  page = site.html_files.find { |f| f.path == "_site/concepts/glossary/index.html" }
  site.fail!("_site/concepts/glossary/index.html is missing") unless page

  missing = site.data["glossary"]["items"].map { |e| e["term"] }.reject { |term| page.body.include?(term) }
  site.fail!("glossary page is missing entry/entries: #{missing.join(', ')}") unless missing.empty?
end
