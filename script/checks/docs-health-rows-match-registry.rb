# frozen_string_literal: true

DOCS_HEALTH_METRIC_ASSERTIONS = {
  "pages missing a description" => "frontmatter-universal-contract",
  "images with empty alt text" => "images-alt-text-present",
  "broken internal links" => "docs-health-links-resolve",
  "pages past their verification horizon" => "page-staleness",
  "orphan pages with zero inbound links" => "orphan-pages-reported"
}.freeze

Check.register(
  id: "docs-health-rows-match-registry",
  desc: "Every metric published on docs-health.md has a corresponding registered assertion",
  covers: ["9.3"]
) do |site|
  registered_ids = Check.registry.map(&:id)

  missing = site.examining("published docs-health metrics", DOCS_HEALTH_METRIC_ASSERTIONS)
                .reject { |_metric, id| registered_ids.include?(id) }
  unless missing.empty?
    details = missing.map { |metric, id| "#{metric.inspect} expects assertion #{id.inspect}" }.join("; ")
    site.fail!("docs-health.md metric(s) with no corresponding registered assertion — #{details}")
  end
end
