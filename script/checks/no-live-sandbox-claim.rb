# frozen_string_literal: true

# NFR2/NFR4 and PROJECT_CONTEXT out-of-scope #2: the agent data plane has no
# hosted sandbox, public base URL, or issued key today. Pages are free to say
# so (and several honestly do, e.g. "not yet open for self-serve") — this
# only bans a POSITIVE claim that one of those three now exists.
Check.register(
  id: "no-live-sandbox-claim",
  desc: "No page asserts that a public base URL, a hosted sandbox, or an issued key exists for the agent data plane",
  covers: ["5.6"]
) do |site|
  claim_patterns = [
    /\bis now open for self-serve\b/i,
    /\bself-serve signup is (?:now )?open\b/i,
    /\bthe plane is (?:now )?live\b/i,
    /\bsandbox is (?:now )?available\b/i,
    /\byour (?:sandbox|plane) (?:api )?key is\b/i,
    %r{https://[a-z0-9.-]*plane[a-z0-9.-]*\.signalsapi\.com}i
  ]

  offenders = site.pages.select { |page| claim_patterns.any? { |pattern| page.body =~ pattern } }

  unless offenders.empty?
    site.fail!("page(s) assert a live sandbox, base URL, or issued key exists — #{offenders.map(&:path).join(', ')}")
  end
end
