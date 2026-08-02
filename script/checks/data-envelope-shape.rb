# frozen_string_literal: true

# AD-7's envelope convention, seeded here against _data/baseline.yml.
# Story 7.1 extends this same assertion id to every _data/*.yml file once
# the DRY refactor gives them all a fact-file shape to match.
Check.register(
  id: "data-envelope-shape",
  desc: "_data/baseline.yml carries exactly a meta: mapping and an items: mapping at the top level",
  covers: ["3.3"]
) do |site|
  data = YAML.safe_load(site.raw("_data/baseline.yml"), permitted_classes: [Date])

  unless data.is_a?(Hash) && data.keys.sort == %w[items meta]
    got = data.is_a?(Hash) ? data.keys.sort.join(", ") : data.class
    site.fail!("_data/baseline.yml must carry exactly `meta:` and `items:` at the top level, got: #{got}")
  end

  missing_meta = %w[owner verified_on source] - data["meta"].keys
  site.fail!("_data/baseline.yml's meta: is missing key(s): #{missing_meta.join(', ')}") unless missing_meta.empty?
end
