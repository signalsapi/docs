# frozen_string_literal: true

Check.register(
  id: "term-include-keys-resolve",
  desc: "Every include term.html key=\"...\" invocation names a term that exists in _data/glossary.yml",
  covers: ["4.3"]
) do |site|
  terms = site.data["glossary"].map { |e| e["term"] }

  offenders = []
  site.pages.each do |page|
    page.body.scan(/include\s+term\.html\s+key=["']([^"']+)["']/) do |match|
      key = match.first
      offenders << "#{page.path}: #{key}" unless terms.include?(key)
    end
  end

  site.fail!("term.html invoked with unresolved key(s): #{offenders.join(', ')}") unless offenders.empty?
end
