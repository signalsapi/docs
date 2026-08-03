# frozen_string_literal: true

# Same pattern as trust-router-complete.rb (9.9): the APIs pages aren't
# nested in a shared directory (api-access.md and the plane pages all still
# live under features/), so this discovers them by parent: APIs instead of
# by path prefix.
Check.register(
  id: "apis-router-covers-children",
  desc: "Every page with parent: APIs is linked from the APIs router's table",
  covers: ["11.5"]
) do |site|
  page_url = lambda do |page|
    page.front_matter["permalink"] || begin
      stripped = page.path.sub(/\.md\z/, "").sub(%r{(\A|/)index\z}, "")
      stripped.empty? ? "/" : "/#{stripped}/"
    end
  end

  router = site.pages.find { |p| p.path == "apis/index.md" }
  site.fail!("apis/index.md is missing") unless router

  children = site.pages.select { |p| p.front_matter["parent"] == "APIs" }
  site.fail!("no page declares parent: APIs") if children.empty?

  missing = children.reject { |p| router.body.include?("(#{page_url.call(p)})") }

  site.fail!("apis/index.md is missing a link to: #{missing.map(&:path).join(', ')}") unless missing.empty?
end
