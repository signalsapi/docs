# frozen_string_literal: true

Check.register(
  id: "llms-full-covers-pages",
  desc: "_site/llms-full.txt concatenates every published page's title into one document",
  covers: ["8.4"]
) do |site|
  site.fail!("_site/llms-full.txt is missing") unless site.exist?("_site/llms-full.txt")

  content = site.raw("_site/llms-full.txt")

  missing = site.pages.select { |p| p.front_matter["page_type"] }
                       .reject { |p| content.include?("# #{p.front_matter['title']}\n") }

  site.fail!("page(s) absent from _site/llms-full.txt — #{missing.map(&:path).join(', ')}") unless missing.empty?
end
