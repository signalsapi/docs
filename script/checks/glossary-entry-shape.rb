# frozen_string_literal: true

Check.register(
  id: "glossary-entry-shape",
  desc: "Every _data/glossary.yml entry has term, definition and owning_page, and no term appears twice",
  covers: ["4.1"]
) do |site|
  entries = site.data["glossary"]["items"]
  site.fail!("_data/glossary.yml is missing or empty") if entries.nil? || entries.empty?

  entries.each_with_index do |entry, i|
    %w[term definition owning_page].each do |key|
      if entry[key].nil? || entry[key].to_s.strip.empty?
        site.fail!("_data/glossary.yml entry #{i} is missing `#{key}`")
      end
    end
  end

  terms = entries.map { |e| e["term"] }.compact
  duplicates = terms.tally.select { |_term, count| count > 1 }.keys
  site.fail!("_data/glossary.yml has duplicate term(s): #{duplicates.join(', ')}") unless duplicates.empty?
end
