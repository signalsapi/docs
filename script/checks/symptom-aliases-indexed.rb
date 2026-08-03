# frozen_string_literal: true

Check.register(
  id: "symptom-aliases-indexed",
  desc: "Every page_type: symptom page's search_aliases values appear in the built lunr search index",
  covers: ["6.3"]
) do |site|
  index_path = "_site/assets/js/search-data.json"
  site.fail!("#{index_path} is missing") unless site.exist?(index_path)

  index_text = site.raw(index_path)

  offenders = []
  site.pages.select { |p| p.front_matter["page_type"] == "symptom" }.each do |page|
    aliases = page.front_matter["search_aliases"] || []
    missing = aliases.reject { |a| index_text.include?(a) }
    offenders << "#{page.path}: #{missing.join(', ')}" unless missing.empty?
  end

  unless offenders.empty?
    site.fail!("search_aliases missing from the built search index — #{offenders.join('; ')}")
  end
end
