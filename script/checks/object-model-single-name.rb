# frozen_string_literal: true

# Scoped to the lead-list object specifically (Story 4.2); Story 4.5's Vale
# rules cover the wider deprecated-alias vocabulary once the term include
# (Story 4.3) gives declared aliases a controlled way to render at all.
Check.register(
  id: "object-model-single-name",
  desc: "No .md file outside the glossary page names the lead-list object with anything but Project or its declared alias",
  covers: ["4.2"]
) do |site|
  entry = site.data["glossary"]["items"].find { |e| e["term"] == "Project" }
  site.fail!("_data/glossary.yml has no entry for Project") unless entry

  normalize = ->(s) { s.downcase.gsub(/\s+/, "").sub(/s\z/, "") }

  declared = (entry["aliases"] || []).map { |a| a.is_a?(Hash) ? a["name"] : a }
  allowed = [entry["term"], *declared].map { |name| normalize.call(name) }

  # A historical changelog: past entries record what shipped and were called
  # at the time, not a name being introduced into today's documentation.
  exempt_paths = %w[whats-new/index.md]

  offenders = []
  site.pages.each do |page|
    next if exempt_paths.include?(page.path)

    page.body.scan(/\b(?:lead\s*lists?|leadlists?)\b/i) do |match|
      offenders << "#{page.path}: #{match.strip}" unless allowed.include?(normalize.call(match))
    end
  end

  site.fail!("undeclared name(s) for the lead-list object: #{offenders.join('; ')}") unless offenders.empty?
end
