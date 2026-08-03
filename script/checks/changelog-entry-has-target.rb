# frozen_string_literal: true

# Story 11.7 moves the changelog into _data/changelog.yml so a shipped
# feature cannot exist only in a changelog paragraph — each entry names the
# page that documents it today. This fails when an entry has no date, names
# no feature, or names a feature that isn't a real page present in the
# built site (proving the reference resolves, not just that a string was
# typed).
Check.register(
  id: "changelog-entry-has-target",
  desc: "every _data/changelog.yml entry has a date and names a feature page present in the built site",
  covers: ["11.7"]
) do |site|
  items = site.data.dig("changelog", "items") || []
  site.fail!("_data/changelog.yml has no items") if items.empty?

  offenders = []

  items.each_with_index do |item, idx|
    offenders << "item #{idx}: missing date" unless item["date"].is_a?(Date)

    feature = item["feature"]
    if feature.to_s.strip.empty?
      offenders << "item #{idx}: missing feature"
      next
    end

    page = site.pages.find { |p| p.path == feature }
    unless page
      offenders << "item #{idx}: feature #{feature} is not a page in the repository"
      next
    end

    permalink = page.front_matter["permalink"] || "/#{page.path.sub(/\.md\z/, '').sub(%r{/index\z}, '')}/"
    built_path = File.join(ROOT, "_site", permalink, "index.html")
    offenders << "item #{idx}: feature #{feature} (#{permalink}) is absent from the built site" unless File.exist?(built_path)
  end

  site.fail!("changelog entry violation(s) — #{offenders.join('; ')}") unless offenders.empty?
end
