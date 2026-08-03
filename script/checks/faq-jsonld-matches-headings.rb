# frozen_string_literal: true

require "json"

Check.register(
  id: "faq-jsonld-matches-headings",
  desc: "The built FAQ page carries one valid FAQPage JSON-LD block whose question count equals its ## heading count",
  covers: ["8.5"]
) do |site|
  faq_path = File.join(ROOT, "_site", "faq", "index.html")
  site.fail!("_site/faq/index.html is missing") unless File.exist?(faq_path)

  html = File.read(faq_path)
  blocks = html.scan(%r{<script type="application/ld\+json">(.*?)</script>}m)
                .map { |m| m.first.strip }
                .select { |b| b.include?('"FAQPage"') }

  site.fail!("faq.md's built page carries #{blocks.size} FAQPage JSON-LD block(s), expected exactly 1") unless blocks.size == 1

  parsed = begin
    JSON.parse(blocks.first)
  rescue JSON::ParserError => e
    site.fail!("faq.md's FAQPage JSON-LD block is not valid JSON — #{e.message}")
  end

  question_count = parsed["mainEntity"].is_a?(Array) ? parsed["mainEntity"].size : 0
  heading_count = site.raw("faq.md").scan(/^## /).size

  unless question_count == heading_count
    site.fail!("faq.md's FAQPage JSON-LD has #{question_count} question(s) but the page has #{heading_count} ## heading(s)")
  end
end
