# frozen_string_literal: true

Check.register(
  id: "concept-page-shape",
  desc: "Every page_type: concept page carries the four required concept headings: " \
        "What it is, Why it matters, How it fits the pipeline, and Related",
  covers: ["4.7"]
) do |site|
  required_headings = ["## What it is", "## Why it matters", "## How it fits the pipeline", "## Related"]

  offenders = []
  site.examining("concept pages", site.pages.select { |p| p.front_matter["page_type"] == "concept" }).each do |page|
    missing = required_headings.reject { |heading| page.body.include?(heading) }
    offenders << "#{page.path} is missing: #{missing.join(', ')}" unless missing.empty?
  end

  site.fail!("concept page shape violation(s) — #{offenders.join('; ')}") unless offenders.empty?
end
