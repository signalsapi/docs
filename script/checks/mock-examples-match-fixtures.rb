# frozen_string_literal: true

# Story 10.5's whole point is that `prism mock openapi/plane-v1.yaml` serves
# the same data as the published fixtures — Prism only does that for a
# response code that carries an example: block; without one it fabricates
# placeholder values from the schema's types alone. This compares each
# fixture (minus its recorded_on stamp) against its operation's own example
# by value, not just by key, so a hand-edited example can't quietly drift
# from the fixture it's supposed to mirror.
Check.register(
  id: "mock-examples-match-fixtures",
  desc: "each operation's example payload in openapi/plane-v1.yaml exactly matches its fixture",
  covers: ["10.5"]
) do |site|
  source_dir = File.join(ROOT, "fixtures", "v1")
  next unless Dir.exist?(source_dir)

  spec = YAML.safe_load(site.raw("openapi/plane-v1.yaml"), permitted_classes: [Date])
  operations = spec["paths"].each_with_object({}) do |(_route, methods), acc|
    methods.each_value { |op| acc[op["operationId"]] = op if op.is_a?(Hash) && op["operationId"] }
  end

  mismatches = []

  Dir.glob(File.join(source_dir, "*.json")).sort.each do |source_path|
    rel = source_path.sub("#{ROOT}/", "")
    _, front_matter_text, body_text = File.read(source_path).split(/^---\s*$/, 3)
    front_matter = YAML.safe_load(front_matter_text.to_s, permitted_classes: [Date]) || {}
    operation_id = front_matter["operation_id"]

    operation = operations[operation_id]
    next unless operation # fixtures-match-spec already flags an operation_id absent from the spec

    success = operation["responses"].find do |code, resp|
      code.match?(/\A2\d\d\z/) && resp.dig("content", "application/json", "schema", "properties")
    end
    next unless success # fixtures-match-spec already flags an operation with no 2xx JSON schema

    example = success[1].dig("content", "application/json", "example")
    unless example
      mismatches << "openapi/plane-v1.yaml: operation #{operation_id} has no example for its 2xx response"
      next
    end

    fixture_payload = (YAML.safe_load(body_text.to_s, permitted_classes: [Date]) || {}).reject { |k, _| k == "recorded_on" }

    next if example == fixture_payload

    mismatches << "#{rel}: fixture diverges from openapi/plane-v1.yaml's example for operation #{operation_id}"
  end

  site.fail!("mock example(s) diverge from their fixture — #{mismatches.join('; ')}") unless mismatches.empty?
end
