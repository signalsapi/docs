# frozen_string_literal: true

# AD-7's envelope convention (Story 3.3 seeded it against _data/baseline.yml;
# Story 7.1 extends it to every _data/*.yml file now that the DRY refactor
# gives them all a fact-file shape to match).
Check.register(
  id: "data-envelope-shape",
  desc: "Every _data/*.yml file carries exactly a meta: mapping (with owner, verified_on, source) and an items: collection",
  covers: %w[3.3 7.1]
) do |site|
  offenders = []

  site.data.each do |name, data|
    path = "_data/#{name}.yml"

    unless data.is_a?(Hash) && data.keys.sort == %w[items meta]
      got = data.is_a?(Hash) ? data.keys.sort.join(", ") : data.class
      offenders << "#{path} must carry exactly `meta:` and `items:` at the top level, got: #{got}"
      next
    end

    missing_meta = %w[owner verified_on source] - data["meta"].keys
    offenders << "#{path}'s meta: is missing key(s): #{missing_meta.join(', ')}" unless missing_meta.empty?
  end

  site.fail!("data envelope violation(s) — #{offenders.join('; ')}") unless offenders.empty?
end
