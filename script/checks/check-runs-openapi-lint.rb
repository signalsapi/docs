# frozen_string_literal: true

# `rake check` is the one command this repo documents as its gate, so every
# stage a contributor has to satisfy must sit behind it. lint:openapi did not:
# it was wired only as its own step in .github/workflows/ci.yml, which fires on
# pull_request and push-to-main. The overhaul branch ran 115 commits without
# opening a pull request, so that step never ran, and the gate anyone could run
# locally could not see the specification at all — two malformed flow-mapping
# descriptions in openapi/plane-v1.yaml survived the whole branch while
# `rake check` reported green.
#
# ci-runs-rake-check and openapi-lint-step-present pin the CI half of that
# wiring; this is the local half. It reads the Rakefile's own declarations —
# the quoted prerequisite list on the `task check:` line, and the
# AGGREGATED_STAGES literal when the task body iterates it — rather than
# grepping the file for the string, so a lint:openapi named only in a comment
# cannot satisfy it. Every branch where those declarations are not where this
# expects them fails loudly instead of passing vacuously.
Check.register(
  id: "check-runs-openapi-lint",
  desc: "Running `rake check` invokes lint:openapi — the Rakefile defines that task and names it among check's prerequisite or aggregated stages",
  covers: ["10.2"]
) do |site|
  rakefile = site.raw("Rakefile")

  unless rakefile.match?(/^namespace :lint do$/) && rakefile.match?(/^\s+task :openapi do$/)
    site.fail!("the Rakefile defines no lint:openapi task — the stage `rake check` has to run is no longer where this assertion pins it")
  end

  check_task = rakefile[/^task check:.*?^end$/m]
  if check_task.nil?
    site.fail!("the Rakefile declares no top-level `task check:` block — `rake check`'s stage set is no longer where this assertion pins it")
  end

  # Stage names come only from the declaration's quoted prerequisite list and,
  # when the body iterates it, the AGGREGATED_STAGES literal — never from prose
  # in the task body.
  stages = check_task.lines.first.scan(/["']([\w:]+)["']/).flatten

  if check_task.include?("AGGREGATED_STAGES")
    aggregated = rakefile[/^AGGREGATED_STAGES\s*=\s*%w\[([^\]]*)\]/m, 1]
    if aggregated.nil?
      site.fail!("`task check:` iterates AGGREGATED_STAGES but the Rakefile declares no `AGGREGATED_STAGES = %w[...]` literal to read those stages from")
    end
    stages += aggregated.split
  end

  unless stages.include?("lint:openapi")
    site.fail!(
      "`rake check` runs #{stages.join(', ')} — not lint:openapi. The documented gate would report green while " \
      "`rake lint:openapi` is red, which is the decoupling this assertion exists to prevent."
    )
  end
end
