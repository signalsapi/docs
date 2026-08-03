# frozen_string_literal: true

# Story 6.4: "each cause names the literal control that resolves it and
# links to its owning page" — operationalized as: the Most likely cause
# section, and every bullet under Other causes, contains a markdown link.
Check.register(
  id: "symptom-causes-linked",
  desc: "Every symptom page's Most likely cause section and each Other causes bullet link to an owning page",
  covers: ["6.4"]
) do |site|
  offenders = []

  site.examining("symptom pages", site.pages.select { |p| p.front_matter["page_type"] == "symptom" }).each do |page|
    most_likely = page.body[/## Most likely cause\n(.*?)(?:\n## |\z)/m, 1]
    offenders << "#{page.path}: Most likely cause has no link" if most_likely && !most_likely.include?("](")

    other_causes = page.body[/## Other causes\n(.*?)(?:\n## |\z)/m, 1]
    next unless other_causes

    bullets = other_causes.split(/\n(?=- )/).select { |b| b.strip.start_with?("- ") }
    unlinked = bullets.reject { |b| b.include?("](") }
    offenders << "#{page.path}: #{unlinked.size} Other causes bullet(s) with no link" unless unlinked.empty?
  end

  site.fail!("symptom page cause(s) missing an owning-page link — #{offenders.join('; ')}") unless offenders.empty?
end
