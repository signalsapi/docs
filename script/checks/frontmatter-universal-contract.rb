# frozen_string_literal: true

Check.register(
  id: "frontmatter-universal-contract",
  desc: "Every page carries title, layout, description and page_type, with description between 50 and 160 characters",
  covers: ["5.2"]
) do |site|
  offenders = []

  site.pages.each do |page|
    missing = %w[title layout description page_type].reject { |key| page.front_matter.key?(key) }
    if missing.any?
      offenders << "#{page.path} is missing: #{missing.join(', ')}"
      next
    end

    length = page.front_matter["description"].to_s.length
    unless length.between?(50, 160)
      offenders << "#{page.path}: description is #{length} characters, not between 50 and 160"
    end
  end

  site.fail!("frontmatter contract violation(s) — #{offenders.join('; ')}") unless offenders.empty?
end
