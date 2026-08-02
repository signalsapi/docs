# frozen_string_literal: true

require "json"

# Each fixture's front matter names the operation_id it stands in for, so a
# schema edit in openapi/plane-v1.yaml and a stale fixture are caught by the
# same commit that would otherwise ship a demo answering with yesterday's
# shape. Reading _site/ (not the source file) also proves layout: null
# actually produced bare, parseable JSON rather than an HTML-wrapped page.
Check.register(
  id: "fixtures-match-spec",
  desc: "each built fixtures/v1/*.json file is valid JSON, carries a recorded_on date, and its top-level keys match its operation's 2xx response schema",
  covers: ["10.3"]
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
    _, front_matter_text, = File.read(source_path).split(/^---\s*$/, 3)
    front_matter = YAML.safe_load(front_matter_text.to_s, permitted_classes: [Date]) || {}
    operation_id = front_matter["operation_id"]
    permalink = front_matter["permalink"]

    operation = operations[operation_id]
    unless operation
      mismatches << "#{rel}: operation_id #{operation_id.inspect} does not match any operationId in openapi/plane-v1.yaml"
      next
    end

    unless permalink
      mismatches << "#{rel}: no permalink in front matter"
      next
    end

    built_path = File.join(ROOT, "_site", permalink)
    unless File.exist?(built_path)
      mismatches << "#{rel}: not present in the built site at _site#{permalink}"
      next
    end

    payload = begin
      JSON.parse(File.read(built_path))
    rescue JSON::ParserError => e
      mismatches << "_site#{permalink}: not valid JSON (#{e.message})"
      next
    end

    unless payload.key?("recorded_on")
      mismatches << "_site#{permalink}: no recorded_on date in the payload"
      next
    end

    success = operation["responses"].find do |code, resp|
      code.match?(/\A2\d\d\z/) && resp.dig("content", "application/json", "schema", "properties")
    end
    unless success
      mismatches << "#{rel}: operation #{operation_id} has no 2xx JSON response schema to compare against"
      next
    end

    schema_keys = success[1].dig("content", "application/json", "schema", "properties").keys.sort
    fixture_keys = (payload.keys - ["recorded_on"]).sort

    next if fixture_keys == schema_keys

    mismatches << "_site#{permalink}: keys #{fixture_keys.inspect} do not match operation #{operation_id}'s response schema keys #{schema_keys.inspect}"
  end

  site.fail!("fixture(s) diverge from their operation's response schema — #{mismatches.join('; ')}") unless mismatches.empty?
end
