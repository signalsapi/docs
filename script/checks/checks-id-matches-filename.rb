# frozen_string_literal: true

Check.register(
  id: "checks-id-matches-filename",
  desc: "Every script/checks/*.rb file registers an id equal to its own basename",
  covers: ["1.11"]
) do |site|
  offenders = Check.registry.reject { |a| a.id == File.basename(a.source, ".rb") }

  unless offenders.empty?
    details = offenders.map { |a| "#{a.source} registers id #{a.id.inspect}" }.join("; ")
    site.fail!("assertion id must equal its file's basename: #{details}")
  end
end
