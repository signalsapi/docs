# frozen_string_literal: true

Check.register(
  id: "baseline-page-renders-all-keys",
  desc: "Every key in _data/baseline.yml appears in the built /docs-baseline/ page",
  covers: ["3.2"]
) do |site|
  page = site.html_files.find { |f| f.path == "_site/docs-baseline/index.html" }
  site.fail!("_site/docs-baseline/index.html is missing") unless page

  missing = site.data.dig("baseline", "items").keys.reject { |key| page.body.include?(key) }
  site.fail!("docs-baseline page is missing key(s): #{missing.join(', ')}") unless missing.empty?
end
