# frozen_string_literal: true

require "cgi"

# Story 8.7: a 1200x630 social card per page, built from the page's own
# title + section and the committed palette (_sass/color_schemes/
# signalsapi.scss) — no designer asset, no image-processing gem, no live
# network call. SVG is plain text, so this needs nothing but string
# building; jekyll-seo-tag already knows how to turn page["image"] into an
# absolute og:image URL once we set it.
module SignalsapiDocs
  class OgCardGenerator < Jekyll::Generator
    BG = "#06070a"
    TEXT = "#e8e8f0"
    MUTED = "#9192a6"
    ACCENT = "#00e87b"
    MAX_CHARS_PER_LINE = 22

    def generate(site)
      content_pages = site.pages.select { |p| p.data["page_type"] }

      content_pages.each do |page|
        card_path = "assets/og/#{slug_for(page)}.svg"

        card = Jekyll::PageWithoutAFile.new(site, site.source, File.dirname(card_path), File.basename(card_path))
        card.content = render_svg(page)
        card.data["layout"] = nil
        card.data["permalink"] = "/#{card_path}"
        site.pages << card

        page.data["image"] = "/#{card_path}"
      end
    end

    private

    def slug_for(page)
      slug = page.url.sub(%r{\A/}, "").sub(%r{/\z}, "").sub(/\.\w+\z/, "")
      slug = "home" if slug.empty?
      slug.tr("/", "-")
    end

    def wrap_title(title)
      words = title.split(" ")
      lines = []
      current = +""

      words.each do |word|
        candidate = current.empty? ? word : "#{current} #{word}"
        if candidate.length > MAX_CHARS_PER_LINE && !current.empty?
          lines << current
          current = +word
        else
          current = candidate
        end
      end
      lines << current unless current.empty?
      lines
    end

    def render_svg(page)
      title_lines = wrap_title(page.data["title"].to_s)
      font_size = title_lines.size > 1 ? 52 : 64
      line_height = (font_size * 1.2).round
      title_top = 315 - (((title_lines.size - 1) * line_height) / 2)

      section = CGI.escapeHTML((page.data["parent"] || "SignalsAPI docs").to_s.upcase)

      title_tspans = title_lines.each_with_index.map do |line, i|
        %(<tspan x="96" y="#{title_top + (i * line_height)}">#{CGI.escapeHTML(line)}</tspan>)
      end.join

      <<~SVG
        <svg xmlns="http://www.w3.org/2000/svg" width="1200" height="630" viewBox="0 0 1200 630">
          <rect width="1200" height="630" fill="#{BG}" />
          <rect x="0" y="0" width="16" height="630" fill="#{ACCENT}" />
          <text x="96" y="160" font-family="DM Sans, sans-serif" font-size="26" letter-spacing="2" fill="#{ACCENT}">#{section}</text>
          <text font-family="DM Sans, sans-serif" font-size="#{font_size}" font-weight="700" fill="#{TEXT}">#{title_tspans}</text>
          <text x="96" y="560" font-family="DM Sans, sans-serif" font-size="22" fill="#{MUTED}">docs.signalsapi.com</text>
        </svg>
      SVG
    end
  end
end
