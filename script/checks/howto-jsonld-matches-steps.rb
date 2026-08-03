# frozen_string_literal: true

require "json"

Check.register(
  id: "howto-jsonld-matches-steps",
  desc: "Every task page's built HTML carries one valid HowTo JSON-LD block whose step count matches its ## Steps list",
  covers: ["8.6"]
) do |site|
  task_pages = site.pages.select { |p| p.front_matter["page_type"] == "task" }
  offenders = []

  task_pages.each do |page|
    html_path = File.join(ROOT, "_site", page.path.sub(/\.md\z/, ""), "index.html")

    unless File.exist?(html_path)
      offenders << "#{page.path}: built page is missing at #{html_path}"
      next
    end

    html = File.read(html_path)
    blocks = html.scan(%r{<script type="application/ld\+json">(.*?)</script>}m)
                 .map { |m| m.first.strip }
                 .select { |b| b.include?('"HowTo"') }

    if blocks.size != 1
      offenders << "#{page.path}: #{blocks.size} HowTo JSON-LD block(s), expected exactly 1"
      next
    end

    parsed = begin
      JSON.parse(blocks.first)
    rescue JSON::ParserError => e
      offenders << "#{page.path}: HowTo JSON-LD block is not valid JSON — #{e.message}"
      next
    end

    json_step_count = parsed["step"].is_a?(Array) ? parsed["step"].size : 0

    steps_section = page.body[/^## Steps\n(.*?)(?=^## |\z)/m, 1] || ""
    heading_step_count = steps_section.scan(/^\d+\. /).size

    if json_step_count != heading_step_count
      offenders << "#{page.path}: HowTo JSON-LD has #{json_step_count} step(s) but ## Steps lists #{heading_step_count}"
    end
  end

  site.fail!("HowTo JSON-LD violation(s) — #{offenders.join('; ')}") unless offenders.empty?
end
