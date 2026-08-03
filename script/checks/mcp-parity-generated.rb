# frozen_string_literal: true

# Story 10.9 replaces the unverifiable "both entry points call the same
# code, so the two can never drift" claim with a computed parity sentence —
# this reads the BUILT sentence and fails if its counts ever diverge from a
# fresh count of openapi/plane-v1.yaml's operations, so the sentence can
# never quietly go stale the way the prose claim it replaced could.
Check.register(
  id: "mcp-parity-generated",
  desc: "the MCP/REST parity sentence on agent-data-plane-mcp.md exactly matches a fresh count of openapi/plane-v1.yaml's operations",
  covers: ["10.9"]
) do |site|
  spec = YAML.safe_load(site.raw("openapi/plane-v1.yaml"), permitted_classes: [Date])
  http_methods = %w[get post put delete patch]

  operations = spec["paths"].flat_map do |_route, methods|
    methods.select { |verb, op| http_methods.include?(verb) && op.is_a?(Hash) }.values
  end

  total = operations.size
  with_mcp_tool = operations.count { |op| op["x-mcp-tool"] }
  rest_only = total - with_mcp_tool

  page = site.html_files.find { |f| f.path == "_site/features/agent-data-plane-mcp/index.html" }
  site.fail!("_site/features/agent-data-plane-mcp/index.html is missing") unless page

  match = page.body.match(/MCP exposes (\d+) of (\d+) operations; (\d+) are REST-only/)
  site.fail!("agent-data-plane-mcp/index.html has no MCP/REST parity sentence") unless match

  rendered = match.captures.map(&:to_i)
  expected = [with_mcp_tool, total, rest_only]

  next if rendered == expected

  site.fail!(
    "rendered parity sentence \"MCP exposes #{rendered[0]} of #{rendered[1]} operations; #{rendered[2]} are REST-only\" " \
    "diverges from the specification (MCP exposes #{expected[0]} of #{expected[1]} operations; #{expected[2]} are REST-only)"
  )
end
