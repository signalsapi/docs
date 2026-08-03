# frozen_string_literal: true

# The rendered "The tools" table on agent-data-plane-mcp.md is built from
# _data/mcp_tools.yml (regenerated from openapi/plane-v1.yaml's x-mcp-tool
# operations by `rake mcp:manifest`), not hand-typed. This reads the BUILT
# page — proving the Liquid template actually renders it, not just that the
# data file exists — and fails if the set of tools it lists ever diverges
# from the spec's own x-mcp-tool set, in either direction.
Check.register(
  id: "mcp-tool-table-generated",
  desc: "the MCP tool table rendered on agent-data-plane-mcp.md exactly matches the x-mcp-tool set in openapi/plane-v1.yaml",
  covers: ["10.6"]
) do |site|
  spec = YAML.safe_load(site.raw("openapi/plane-v1.yaml"), permitted_classes: [Date])
  spec_tools = spec["paths"].flat_map do |_route, methods|
    methods.filter_map { |_verb, op| op["x-mcp-tool"] if op.is_a?(Hash) }
  end.sort

  site.fail!("openapi/plane-v1.yaml declares no x-mcp-tool operations") if spec_tools.empty?

  page = site.html_files.find { |f| f.path == "_site/features/agent-data-plane-mcp/index.html" }
  site.fail!("_site/features/agent-data-plane-mcp/index.html is missing") unless page

  section = page.body[/<h2 id="the-tools">.*?(?=<h2 |\z)/m]
  site.fail!("agent-data-plane-mcp/index.html has no 'The tools' section") unless section

  rendered_tools = section.scan(%r{<tr>\s*<td><code[^>]*>([a-z_]+)</code></td>}).flatten.sort

  next if rendered_tools == spec_tools

  site.fail!(
    "rendered tool table #{rendered_tools.inspect} diverges from openapi/plane-v1.yaml's x-mcp-tool set #{spec_tools.inspect}"
  )
end
