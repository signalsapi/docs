# frozen_string_literal: true

Check.register(
  id: "verified-on-rendered",
  desc: "Every page's built HTML shows its own verified_on date",
  covers: ["9.2"]
) do |site|
  offenders = []

  site.pages.each do |page|
    verified_on = page.front_matter["verified_on"]
    next unless verified_on.is_a?(Date)

    rel = page.front_matter["permalink"] || begin
      stripped = page.path.sub(/\.md\z/, "").sub(%r{(\A|/)index\z}, "")
      stripped.empty? ? "/" : "/#{stripped}/"
    end

    html_path = if rel.end_with?("/")
                  File.join(ROOT, "_site", rel, "index.html")
                else
                  File.join(ROOT, "_site", rel)
                end

    unless File.exist?(html_path)
      offenders << "#{page.path}: built page missing at #{rel}"
      next
    end

    formatted = verified_on.strftime("%Y-%m-%d")
    unless File.read(html_path).include?(formatted)
      offenders << "#{page.path}: verified_on #{formatted} not found in its built HTML"
    end
  end

  site.fail!("verified_on rendering violation(s) — #{offenders.join('; ')}") unless offenders.empty?
end
