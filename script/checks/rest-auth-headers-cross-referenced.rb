# frozen_string_literal: true

# signalsapi-5526: the self-serve REST API (`Authorization: Bearer`) and the
# agent data plane (`X-API-Key`) use two incompatible, non-interchangeable
# auth headers. Before this, only troubleshooting/api-auth.md named both —
# reached only after a developer already sent the wrong one and got a
# 401/403. Each surface's own Authentication section must name the other
# header so the warning is visible before the mistake.
PAGES_AND_OTHER_HEADER = {
  "features/api-access.md" => "X-API-Key",
  "features/agent-data-plane-api.md" => "Authorization: Bearer"
}.freeze

Check.register(
  id: "rest-auth-headers-cross-referenced",
  desc: "Each REST reference page's Authentication section names the other surface's incompatible auth header"
) do |site|
  offenders = []

  site.examining("REST reference pages", PAGES_AND_OTHER_HEADER.keys).each do |path|
    other_header = PAGES_AND_OTHER_HEADER.fetch(path)
    body = site.raw(path)
    auth_section = body[/## Authentication\n(.*?)(?:\n## |\z)/m, 1]

    if auth_section.nil?
      offenders << "#{path}: no ## Authentication section"
    elsif !auth_section.include?(other_header)
      offenders << "#{path}: Authentication section doesn't mention `#{other_header}`"
    end
  end

  site.fail!("auth header cross-reference missing — #{offenders.join('; ')}") unless offenders.empty?
end
