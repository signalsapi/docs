# frozen_string_literal: true

Check.register(
  id: "troubleshooting-router-complete",
  desc: "Every page under troubleshooting/ is linked from the troubleshooting router's link list",
  covers: ["6.1"]
) do |site|
  page_url = lambda do |path|
    rel = path.sub(/\.md\z/, "").sub(%r{/index\z}, "")
    "/#{rel}/"
  end

  router = site.pages.find { |p| p.path == "troubleshooting/index.md" }
  site.fail!("troubleshooting/index.md is missing") unless router

  symptom_pages = site.pages.select do |p|
    p.path.start_with?("troubleshooting/") && p.path != "troubleshooting/index.md"
  end

  missing = symptom_pages.reject { |p| router.body.include?("(#{page_url.call(p.path)})") }

  unless missing.empty?
    site.fail!("troubleshooting/index.md is missing a link to: #{missing.map(&:path).join(', ')}")
  end
end
