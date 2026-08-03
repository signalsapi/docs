# frozen_string_literal: true

Check.register(
  id: "checks-one-per-file",
  desc: "Each script/checks/*.rb file calls Check.register exactly once (AD-3)",
  covers: ["1.6"]
) do |site|
  offenders = site.examining("registered assertions", Check.registry)
                  .group_by(&:source).select { |_source, assertions| assertions.size > 1 }

  unless offenders.empty?
    details = offenders.map do |source, assertions|
      "#{source} (#{assertions.size}x: #{assertions.map(&:id).join(', ')})"
    end.join("; ")

    site.fail!("Check.register called more than once in: #{details}")
  end
end
