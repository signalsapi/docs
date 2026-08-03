# frozen_string_literal: true

Check.register(
  id: "frontmatter-universal-contract",
  desc: "Every page carries title, layout, description and page_type",
  covers: ["5.2"]
) do |site|
  offenders = []

  site.pages.each do |page|
    missing = %w[title layout description page_type].reject { |key| page.front_matter.key?(key) }
    offenders << "#{page.path} is missing: #{missing.join(', ')}" if missing.any?
  end

  site.fail!("frontmatter contract violation(s) — #{offenders.join('; ')}") unless offenders.empty?
end
