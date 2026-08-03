# frozen_string_literal: true

Check.register(
  id: "vale-aliases-match-glossary",
  desc: "The alias set in styles/SignalsAPI/DeprecatedAliases.yml matches the alias set in _data/glossary.yml",
  covers: ["4.5"]
) do |site|
  normalize = ->(s) { s.downcase.strip.sub(/s\z/, "") }

  glossary_aliases = site.data["glossary"]["items"].flat_map do |entry|
    (entry["aliases"] || []).map { |a| a.is_a?(Hash) ? a["name"] : a }
  end
  glossary_set = glossary_aliases.map { |a| normalize.call(a) }.uniq.sort

  vale_rule = YAML.safe_load(site.raw("styles/SignalsAPI/DeprecatedAliases.yml"))
  vale_set = (vale_rule["tokens"] || []).map { |t| normalize.call(t) }.uniq.sort

  if glossary_set != vale_set
    site.fail!("alias sets diverge — _data/glossary.yml: #{glossary_set.inspect}, DeprecatedAliases.yml: #{vale_set.inspect}")
  end
end
