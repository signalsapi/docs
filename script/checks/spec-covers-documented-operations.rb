# frozen_string_literal: true

# features/agent-data-plane-api.md is the one page that declares each
# operation in the canonical "METHOD /path" fenced-text form this scans for
# — features/agent-data-plane-clay.md references /v1/clay/enrich in prose
# and curl examples only, never in that form, so it isn't a second source
# to scan.
Check.register(
  id: "spec-covers-documented-operations",
  desc: "openapi/plane-v1.yaml covers every operation documented on features/agent-data-plane-api.md, each with a valid x-status",
  covers: ["10.1"]
) do |site|
  spec_path = File.join(ROOT, "openapi", "plane-v1.yaml")
  site.fail!("openapi/plane-v1.yaml is missing") unless File.exist?(spec_path)

  spec = YAML.safe_load(File.read(spec_path), permitted_classes: [Date])
  site.fail!("openapi/plane-v1.yaml has no paths:") unless spec["paths"]

  http_methods = %w[get post put delete patch]
  valid_statuses = %w[live code-complete planned]

  documented = site.raw("features/agent-data-plane-api.md")
                   .scan(%r{^(GET|POST|DELETE|PUT|PATCH) (/v1/\S*)}m)
                   .map { |method, route| "#{method} #{route.split('?').first}" }
                   .uniq
  site.fail!("no operations found in features/agent-data-plane-api.md") if documented.empty?

  spec_ops = spec["paths"].flat_map do |route, methods|
    methods.select { |m, _| http_methods.include?(m) }.keys.map { |m| "#{m.upcase} #{route}" }
  end

  missing_from_spec = documented - spec_ops
  unless missing_from_spec.empty?
    site.fail!("operation(s) documented in prose but absent from openapi/plane-v1.yaml — #{missing_from_spec.join(', ')}")
  end

  missing_status = spec["paths"].flat_map do |route, methods|
    methods.select { |m, op| http_methods.include?(m) && !valid_statuses.include?(op["x-status"]) }
           .map { |m, _| "#{m.upcase} #{route}" }
  end
  unless missing_status.empty?
    site.fail!("operation(s) with no valid x-status (must be live, code-complete, or planned) — #{missing_status.join(', ')}")
  end
end
