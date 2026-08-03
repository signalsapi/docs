# frozen_string_literal: true

# mcp-tool-table-generated pins the *set* of tools _data/mcp_tools.yml lists,
# not their argument lists — so a parameter added to the specification and
# never regenerated into the manifest would render a stale table with a green
# build. Idempotency-Key is the parameter that most needs the pin: MCP has no
# request headers, so it reaches a tool only under the separate name the
# specification declares in x-mcp-arg, and that indirection is exactly where a
# regeneration gets skipped or a header leaks through under its REST spelling.
Check.register(
  id: "mcp-tool-args-carry-idempotency-key",
  desc: "_data/mcp_tools.yml lists the Idempotency-Key header's x-mcp-arg name on exactly the MCP tools whose openapi/plane-v1.yaml operation declares that header",
  covers: ["10.6"]
) do |site|
  spec = YAML.safe_load(site.raw("openapi/plane-v1.yaml"), permitted_classes: [Date])

  header = spec.dig("components", "parameters", "IdempotencyKey")
  site.fail!("openapi/plane-v1.yaml declares no components.parameters.IdempotencyKey") unless header

  mcp_arg = header["x-mcp-arg"]
  site.fail!("components.parameters.IdempotencyKey declares no x-mcp-arg — MCP has no headers, so it would reach no tool") if mcp_arg.to_s.empty?

  expected = spec["paths"].each_with_object({}) do |(_route, methods), acc|
    methods.each_value do |op|
      next unless op.is_a?(Hash) && op["x-mcp-tool"]

      refs = (op["parameters"] || []).filter_map { |p| p["$ref"] }
      acc[op["x-mcp-tool"]] = refs.include?("#/components/parameters/IdempotencyKey")
    end
  end
  site.fail!("openapi/plane-v1.yaml declares no x-mcp-tool operations") if expected.empty?
  site.fail!("no x-mcp-tool operation references components.parameters.IdempotencyKey") unless expected.value?(true)

  manifest = site.data["mcp_tools"]
  items = manifest.is_a?(Hash) ? manifest["items"] : nil
  site.fail!("_data/mcp_tools.yml has no items:") if items.nil? || items.empty?

  mismatches = []
  expected.each do |tool, should_carry|
    item = items.find { |i| i["tool"] == tool }
    next mismatches << "#{tool}: declared in the specification but absent from _data/mcp_tools.yml" unless item

    carries = (item["args"] || []).any? { |arg| arg.sub(/\?\z/, "") == mcp_arg }
    next if carries == should_carry

    mismatches << if should_carry
                    "#{tool}: its operation declares Idempotency-Key but _data/mcp_tools.yml lists no #{mcp_arg} argument " \
                    "(run `rake mcp:manifest`)"
                  else
                    "#{tool}: _data/mcp_tools.yml lists a #{mcp_arg} argument but its operation declares no Idempotency-Key"
                  end
  end

  # A header parameter must never surface under its REST spelling: mcp/server.js
  # forwards path and query parameters only, so an argument named after the
  # header would be advertised to an agent and then silently dropped.
  items.each do |item|
    next unless (item["args"] || []).any? { |arg| arg.sub(/\?\z/, "") == header["name"] }

    mismatches << "#{item['tool']}: _data/mcp_tools.yml advertises the raw header name #{header['name']} as an argument"
  end

  site.fail!("_data/mcp_tools.yml diverges from the specification's Idempotency-Key set — #{mismatches.join('; ')}") unless mismatches.empty?
end
