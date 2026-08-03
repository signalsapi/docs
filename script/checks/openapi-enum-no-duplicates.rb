# frozen_string_literal: true

# .spectral.yaml turns duplicated-entry-in-enum off because Spectral 6.16.2
# crashes on the literal null the whoami example needs (see the comment
# there). This restores the coverage the rule provided: every enum in the
# specification, wherever it is nested, holds distinct values.
Check.register(
  id: "openapi-enum-no-duplicates",
  desc: "no enum in openapi/plane-v1.yaml repeats a value (replaces Spectral's disabled duplicated-entry-in-enum)",
  covers: ["10.2"]
) do |site|
  spec_path = File.join(ROOT, "openapi", "plane-v1.yaml")
  next unless File.exist?(spec_path)

  spec = YAML.safe_load(site.raw("openapi/plane-v1.yaml"), permitted_classes: [Date])
  offenders = []

  walk = lambda do |node, path|
    case node
    when Hash
      values = node["enum"]
      if values.is_a?(Array) && values.uniq.size != values.size
        repeated = values.tally.select { |_, n| n > 1 }.keys
        offenders << "#{path}/enum repeats #{repeated.map(&:inspect).join(', ')}"
      end
      node.each { |key, value| walk.call(value, "#{path}/#{key}") }
    when Array
      node.each_with_index { |value, index| walk.call(value, "#{path}/#{index}") }
    end
  end
  walk.call(spec, "")

  site.fail!("duplicate enum entries: #{offenders.join('; ')}") unless offenders.empty?
end
