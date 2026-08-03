# frozen_string_literal: true

# features/agent-data-plane-api.md promises that every *metered* route accepts
# an optional Idempotency-Key request header — but prose is not what a machine
# reads. _data/mcp_tools.yml, _data/plane_status.yml, mcp/server.js and the
# Prism mock are all generated from openapi/plane-v1.yaml, so a contract that
# lives only in the prose is a contract no agent can discover.
#
# This pins the two together in both directions. The metered set is *derived*
# from the docs' own billing prose rather than listed here, so it cannot be
# satisfied by editing this file: an operation counts as metered when the
# paragraph documenting it — its own ### block, the ## section it sits under,
# or the ## Billing section of a page it defers to — both uses a billing verb
# and names one of the meter units or meter classes features/agent-data-plane.md
# itself declares.
Check.register(
  id: "idempotency-key-on-metered-operations",
  desc: "openapi/plane-v1.yaml declares the Idempotency-Key header on exactly the operations features/agent-data-plane-api.md documents as metered",
  covers: ["10.1"]
) do |site|
  spec = YAML.safe_load(site.raw("openapi/plane-v1.yaml"), permitted_classes: [Date])
  http_methods = %w[get post put delete patch]

  resolve = lambda do |node|
    node["$ref"] ? node["$ref"].sub(%r{\A#/}, "").split("/").reduce(spec) { |n, key| n[key] } : node
  end

  spec_with_header = spec["paths"].flat_map do |route, methods|
    methods.filter_map do |verb, op|
      next unless http_methods.include?(verb) && op.is_a?(Hash)

      params = (op["parameters"] || []).map { |p| resolve.call(p) }
      next unless params.any? { |p| p["in"] == "header" && p["name"] == "Idempotency-Key" }

      "#{verb.upcase} #{route}"
    end
  end.sort

  # Vacuity guard: with no header anywhere in the spec this assertion would
  # otherwise reduce to "the docs document nothing as metered", which is the
  # exact gap it exists to catch.
  site.fail!("openapi/plane-v1.yaml declares no Idempotency-Key header parameter on any operation") if spec_with_header.empty?

  # The vocabulary is the overview page's own, not a list maintained here —
  # rename a meter unit there and this follows.
  overview = site.raw("features/agent-data-plane.md")
  units = overview[/^Four meter units are recorded: ([^\n]+)\./, 1].to_s.scan(/`([a-z_]+)`/).flatten
  classes = overview.scan(/class `([a-z_]+)`/).flatten.uniq
  site.fail!("features/agent-data-plane.md no longer declares the meter units ('Four meter units are recorded: …')") if units.empty?
  site.fail!("features/agent-data-plane.md no longer declares any meter class ('class `…`')") if classes.empty?

  billing_tokens = (units + classes).uniq
  billing_verb = /\b(bills?|billed|billing|meters?|metered|metering)\b/i

  # Fenced blocks are request/response examples, not claims about billing —
  # /v1/usage's own response body names every meter unit there is.
  strip_fences = ->(text) { text.gsub(/^```.*?^```/m, "") }

  declares_billing = lambda do |text|
    strip_fences.call(text).split(/\n[ \t]*\n/).any? do |paragraph|
      paragraph.match?(billing_verb) && billing_tokens.any? { |token| paragraph.include?("`#{token}`") }
    end
  end

  # An operation the API page documents by pointing elsewhere (Clay) is billed
  # by that page's ## Billing section, which is then its billing prose.
  deferred_billing = lambda do |block|
    block.scan(/\]\(([^)\s]+)\)/).flatten.filter_map do |target|
      slug = target.split("#").first.to_s.split("/").reject(&:empty?).last
      next unless slug

      page = site.pages.find { |p| File.basename(p.path, ".md") == slug }
      next unless page

      section = site.raw(page.path)[/^## Billing\b.*?(?=^## |\z)/m]
      section unless section.to_s.empty?
    end.join("\n\n")
  end

  documented = {}
  site.raw("features/agent-data-plane-api.md").split(/^(?=## )/).each do |section|
    blocks = section.split(/^(?=### )/)
    section_is_metered = declares_billing.call(blocks.shift.to_s)

    blocks.each do |block|
      routes = block.scan(%r{^(GET|POST|DELETE|PUT|PATCH) (/v1/\S*)})
                    .map { |method, route| "#{method} #{route.split('?').first}" }.uniq
      next if routes.empty?

      metered = section_is_metered || declares_billing.call("#{block}\n\n#{deferred_billing.call(block)}")
      routes.each { |route| documented[route] = metered }
    end
  end

  site.fail!("no operations found in features/agent-data-plane-api.md") if documented.empty?

  docs_metered = documented.select { |_route, metered| metered }.keys.sort
  site.fail!("features/agent-data-plane-api.md documents no operation as metered") if docs_metered.empty?

  missing = docs_metered - spec_with_header
  extra = spec_with_header - docs_metered
  next if missing.empty? && extra.empty?

  problems = []
  unless missing.empty?
    problems << "documented as metered but carrying no Idempotency-Key parameter in openapi/plane-v1.yaml — #{missing.join(', ')}"
  end
  unless extra.empty?
    problems << "carrying Idempotency-Key in openapi/plane-v1.yaml but not documented as metered on features/agent-data-plane-api.md — #{extra.join(', ')}"
  end

  site.fail!("the Idempotency-Key set and the documented metered set disagree: #{problems.join('; ')}")
end
