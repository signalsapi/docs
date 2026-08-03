# frozen_string_literal: true

require "json"

# /plane-status.json renders from _data/plane_status.yml (regenerated from
# openapi/plane-v1.yaml by `rake plane:manifest`), not hand-typed. This reads
# the BUILT document — proving layout: null produced bare JSON and that the
# Liquid template actually renders every operation — and fails if it and the
# live spec ever disagree about any operation's status or MCP tool.
Check.register(
  id: "plane-status-matches-spec",
  desc: "the built /plane-status.json exactly matches every operation's x-status and x-mcp-tool in openapi/plane-v1.yaml",
  covers: ["10.7"]
) do |site|
  spec = YAML.safe_load(site.raw("openapi/plane-v1.yaml"), permitted_classes: [Date])
  http_methods = %w[get post put delete patch]

  spec_operations = spec["paths"].each_with_object({}) do |(route, methods), acc|
    methods.each do |verb, op|
      next unless http_methods.include?(verb) && op.is_a?(Hash) && op["operationId"]

      acc[op["operationId"]] = {
        "method" => verb.upcase,
        "path" => route,
        "status" => op["x-status"],
        "mcp_tool" => op["x-mcp-tool"]
      }
    end
  end

  built_path = File.join(ROOT, "_site", "plane-status.json")
  site.fail!("_site/plane-status.json is missing") unless File.exist?(built_path)

  document = JSON.parse(File.read(built_path))
  built_operations = document["operations"] || []
  site.fail!("_site/plane-status.json has no operations") if built_operations.empty?

  mismatches = []
  built_ids = built_operations.map { |op| op["operation_id"] }

  spec_operations.each do |operation_id, expected|
    built = built_operations.find { |op| op["operation_id"] == operation_id }
    unless built
      mismatches << "#{operation_id}: present in the specification but missing from plane-status.json"
      next
    end

    actual = built.slice("method", "path", "status", "mcp_tool")
    next if actual == expected

    mismatches << "#{operation_id}: plane-status.json has #{actual.inspect}, specification declares #{expected.inspect}"
  end

  extra = built_ids - spec_operations.keys
  extra.each { |operation_id| mismatches << "#{operation_id}: present in plane-status.json but absent from the specification" }

  site.fail!("plane-status.json diverges from openapi/plane-v1.yaml — #{mismatches.join('; ')}") unless mismatches.empty?
end
