# frozen_string_literal: true

Check.register(
  id: "task-page-shape",
  desc: "Every page_type: task page carries the four required task headings: " \
        "Before you start, Steps, Check it worked, and If it did not work",
  covers: ["5.4"]
) do |site|
  required_headings = ["## Before you start", "## Steps", "## Check it worked", "## If it did not work"]

  offenders = []
  site.examining("task pages", site.pages.select { |p| p.front_matter["page_type"] == "task" }).each do |page|
    missing = required_headings.reject { |heading| page.body.include?(heading) }
    offenders << "#{page.path} is missing: #{missing.join(', ')}" unless missing.empty?
  end

  site.fail!("task page shape violation(s) — #{offenders.join('; ')}") unless offenders.empty?
end
