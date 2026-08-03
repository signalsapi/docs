# frozen_string_literal: true

# GitHub deprecated the Node 20 runtime on Actions runners and now *forces* any
# action declaring `runs.using: node20` onto Node 24 — a runtime that action was
# never released against. Every run of this repository carried the resulting
# warning until signalsapi-4300, and this is the repository where losing CI costs
# the most: `bundle` and `jekyll` are absent on a contributor's machine, so CI is
# the only thing that can run check:build, check:links and check:prose at all.
# A broken CI here is not a degraded gate, it is no gate. The warning is also the
# shape that gets ignored until it is not — nothing goes red on it, exactly like
# the Spectral warning Story 10.2 had to clear by hand.
#
# Each floor below is the FIRST major that declares node24, read off that
# action's own `runs.using` rather than guessed, so a pin at the floor fixes the
# runtime and adopts nothing else:
#
#   actions/checkout                    v4 node20  ->  v5 node24
#   actions/setup-node                  v4 node20  ->  v5 node24
#   actions/configure-pages             v5 node20  ->  v6 node24
#   actions/deploy-pages                v4 node20  ->  v5 node24
#   peter-evans/create-issue-from-file  v5 node20  ->  v6 node24
#
# actions/upload-pages-artifact is the one that cannot be read off its own
# action.yml at all: it is a composite, and the deprecated runtime rides the
# actions/upload-artifact it calls internally. v3 calls `@v4` (node20) and — the
# part that makes a version-watch miss it — so does v4, via `@v4.6.2`. v5 is the
# first that pins upload-artifact@v7.0.0 (node24), so bumping to v4 would read
# like a fix and be inert.
#
# ruby/setup-ruby@v1 already declares node24, and lycheeverse/lychee-action@v2 is
# a composite of shell steps only, so neither carries a floor above its pin.
#
# An action with no entry here fails rather than passing quietly: the way this
# regresses is a new action added without anyone asking what runtime it declares.
#
# Both of the ways this assertion could be dodged were ways of never being shown
# the step at all, and neither looked wrong on the page (signalsapi-4306): a
# workflow saved as `.yaml`, which GitHub runs and a `*.yml` glob does not
# collect, and a step written `- uses:` on one line, which is ordinary YAML and
# the form GitHub's own examples use. Both are read here now — the extension
# pair via Site#workflows, the inline step via the optional list marker below.
Check.register(
  id: "actions-not-on-deprecated-node",
  desc: "no workflow pins an action whose runtime is the deprecated Node 20, or asks for Node 20 itself",
  covers: ["1.10"]
) do |site|
  # Minimum major whose `runs.using` is node24. Transcribed, not derived — the
  # assertion has no network, and a floor that moved on its own would not be a
  # floor. Raise an entry when its action ships a newer runtime requirement.
  floors = {
    "actions/checkout" => 5,
    "actions/setup-node" => 5,
    "actions/configure-pages" => 6,
    "actions/upload-pages-artifact" => 5,
    "actions/deploy-pages" => 5,
    "peter-evans/create-issue-from-file" => 6,
    "ruby/setup-ruby" => 1,
    "lycheeverse/lychee-action" => 2
  }.freeze

  workflows = site.examining("workflow files", site.workflows)

  below_floor = []
  unrecognised = []
  unreadable_ref = []
  deprecated_node = []

  workflows.each do |path|
    site.raw(path).each_line.with_index(1) do |line, number|
      if (step = line.match(%r{^\s*(?:-\s*)?uses:\s*["']?(?<action>[\w.-]+/[\w.-]+)@(?<ref>[^\s"']+)}))
        action = step[:action]
        ref = step[:ref]
        floor = floors[action]
        major = ref[/\Av(\d+)/, 1]

        if floor.nil?
          unrecognised << "#{path}:#{number} #{action}@#{ref}"
        elsif major.nil?
          unreadable_ref << "#{path}:#{number} #{action}@#{ref}"
        elsif major.to_i < floor
          below_floor << "#{path}:#{number} #{action}@#{ref} needs v#{floor} or newer"
        end
      elsif (request = line.match(/^\s*node-version:\s*["']?(?<version>\d+)/))
        next unless request[:version].to_i < 24

        deprecated_node << "#{path}:#{number} node-version: #{request[:version]}"
      end
    end
  end

  unless below_floor.empty?
    site.fail!("these actions run on the deprecated Node 20 runtime: #{below_floor.join('; ')}")
  end

  unless deprecated_node.empty?
    site.fail!(
      "these steps install a Node the runner no longer runs actions on: #{deprecated_node.join('; ')} — " \
      "ask for 24 or newer"
    )
  end

  unless unrecognised.empty?
    site.fail!(
      "no runtime floor recorded for: #{unrecognised.join('; ')} — read the action's `runs.using` " \
      "(following any composite's nested `uses:`) and add it to this assertion's floors"
    )
  end

  unless unreadable_ref.empty?
    site.fail!(
      "cannot tell which major these are pinned to: #{unreadable_ref.join('; ')} — " \
      "pin a `vN` tag, or record the major this ref resolves to here"
    )
  end
end
