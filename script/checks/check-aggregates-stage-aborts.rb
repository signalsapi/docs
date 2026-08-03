# frozen_string_literal: true

# AD-5 states the contract `rake check` means to keep: once check:build
# succeeds, "every other stage runs to completion and their failures are
# aggregated into one report." Two aggregated stages broke that promise
# whenever a pinned tool was absent. check:prose without vale and lint:openapi
# without spectral each report it with `abort`, which raises SystemExit —
# and SystemExit descends from Exception, not StandardError, so an aggregator
# rescuing StandardError alone could not see it. The rake process ended at that
# stage: every later stage silently never ran, its verdict was unknown rather
# than green, and the aggregate report — including whatever an earlier stage had
# already found — was discarded. CI installs both binaries, so it was invisible
# there and only ever cost the local contributor AD-12 and Story 10.2 are
# written to serve.
#
# This reads the Rakefile's own declarations rather than grepping it: the
# AGGREGATED_STAGES literal, the body of each stage it names, and the rescue
# clause on `task check:`'s aggregation loop. A SystemExit named only in a
# comment cannot satisfy it. The requirement is conditional on a stage actually
# being able to raise SystemExit — if none can, there is genuinely nothing to
# rescue — which is why a stage body this cannot locate fails loudly instead of
# being skipped into a vacuous pass.
Check.register(
  id: "check-aggregates-stage-aborts",
  desc: "`rake check`'s aggregation loop rescues every way its stages can terminate, including the SystemExit an `abort` for a missing pinned tool raises",
  covers: ["1.10"]
) do |site|
  rakefile = site.raw("Rakefile")

  check_task = rakefile[/^task check:.*?^end$/m]
  if check_task.nil?
    site.fail!("the Rakefile declares no top-level `task check:` block — the aggregation loop this assertion pins is no longer where it expects it")
  end

  unless check_task.include?("AGGREGATED_STAGES")
    site.fail!("`task check:`'s body no longer iterates AGGREGATED_STAGES — this assertion can no longer tell which stages the aggregator runs")
  end

  literal = rakefile[/^AGGREGATED_STAGES\s*=\s*%w\[([^\]]*)\]/m, 1]
  if literal.nil?
    site.fail!("`task check:` iterates AGGREGATED_STAGES but the Rakefile declares no `AGGREGATED_STAGES = %w[...]` literal to read those stages from")
  end
  stages = literal.split

  # A namespaced stage's body is its `task :name do ... end` block, whose `end`
  # is the only one indented to the namespace's two columns.
  stage_body = lambda do |stage|
    namespace, task_name = stage.split(":")
    next nil unless namespace && task_name

    namespace_block = rakefile[/^namespace :#{Regexp.escape(namespace)} do$.*?^end$/m]
    next nil unless namespace_block

    namespace_block[/^  task :#{Regexp.escape(task_name)}\b[^\n]*\bdo\b.*?^  end$/m]
  end

  unreadable = stages.reject { |stage| stage_body.call(stage) }
  unless unreadable.empty?
    site.fail!(
      "this assertion cannot locate a task body for #{unreadable.join(', ')}, so it cannot tell how #{unreadable.size == 1 ? 'that stage' : 'those stages'} " \
      "can terminate. Failing loudly rather than reporting a coupling it can no longer see."
    )
  end

  # `abort` and `exit` raise SystemExit; `sh` and everything else raise a
  # StandardError the aggregator has always caught.
  exits_the_process = lambda do |body|
    body.lines.reject { |line| line.strip.start_with?("#") }.any? { |line| line.match?(/^\s*(abort|exit)\b/) }
  end

  exiting = stages.select { |stage| exits_the_process.call(stage_body.call(stage)) }

  rescued = check_task[/^\s*rescue\s+([^\n=]*?)\s*=>/, 1]
  if rescued.nil?
    site.fail!("`task check:`'s aggregation loop declares no `rescue ... =>` clause, so a single failing stage ends the whole run instead of being aggregated")
  end
  rescued_classes = rescued.split(",").map(&:strip)

  if exiting.any? && !rescued_classes.intersect?(%w[SystemExit Exception])
    site.fail!(
      "#{exiting.join(' and ')} can end the process with `abort`/`exit` (SystemExit), but `rake check`'s aggregation loop rescues only " \
      "#{rescued_classes.empty? ? 'StandardError' : rescued_classes.join(', ')}. SystemExit does not descend from StandardError, so a contributor " \
      "missing one pinned tool gets the run terminated at that stage — every later stage never runs and the aggregate report is never printed, " \
      "which is the opposite of the AD-5 contract the task documents."
    )
  end
end
