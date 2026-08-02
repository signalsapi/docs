# frozen_string_literal: true

Check.register(
  id: "task-links-troubleshooting",
  desc: "Every task page's If it did not work section links to /troubleshooting/, and every symptom page " \
        "is reachable from at least one task page",
  covers: ["6.11"]
) do |site|
  task_pages = site.pages.select { |p| p.front_matter["page_type"] == "task" }
  symptom_pages = site.pages.select { |p| p.front_matter["page_type"] == "symptom" }

  linked_troubleshooting_urls = []
  offenders = []

  task_pages.each do |page|
    section = page.body[/## If it did not work\n(.*?)(?:\n## |\z)/m, 1]
    if section.nil?
      offenders << "#{page.path}: no '## If it did not work' section"
      next
    end

    urls = section.scan(%r{\]\((/troubleshooting/[^)]*)\)}).flatten
    offenders << "#{page.path}: no link to /troubleshooting/ in If it did not work" if urls.empty?
    linked_troubleshooting_urls.concat(urls)
  end

  site.fail!("task page shape violation(s) — #{offenders.join('; ')}") unless offenders.empty?

  symptom_url = lambda do |path|
    rel = path.sub(/\.md\z/, "").sub(%r{/index\z}, "")
    "/#{rel}/"
  end

  unreachable = symptom_pages.reject { |p| linked_troubleshooting_urls.include?(symptom_url.call(p.path)) }
  unless unreachable.empty?
    site.fail!("symptom page(s) not linked from any task page's If it did not work — #{unreachable.map(&:path).join(', ')}")
  end
end
