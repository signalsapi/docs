# frozen_string_literal: true

# troubleshooting-router-complete (6.1) discovers its children by path
# prefix (troubleshooting/); the trust pages aren't nested in a shared
# directory (they live at repo root, same pattern as quick-start.md's own
# children), so this discovers them by parent: Trust instead.
Check.register(
  id: "trust-router-complete",
  desc: "Every page with parent: Trust is linked from the trust router's link list",
  covers: ["9.9"]
) do |site|
  page_url = lambda do |page|
    page.front_matter["permalink"] || begin
      stripped = page.path.sub(/\.md\z/, "").sub(%r{(\A|/)index\z}, "")
      stripped.empty? ? "/" : "/#{stripped}/"
    end
  end

  router = site.pages.find { |p| p.path == "trust.md" }
  site.fail!("trust.md is missing") unless router

  children = site.pages.select { |p| p.front_matter["parent"] == "Trust" }
  site.fail!("no page declares parent: Trust") if children.empty?

  missing = children.reject { |p| router.body.include?("(#{page_url.call(p)})") }

  site.fail!("trust.md is missing a link to: #{missing.map(&:path).join(', ')}") unless missing.empty?
end
