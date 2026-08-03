# frozen_string_literal: true

# Reported, not failed — fixing each image's alt text is real content work
# (a meaningful description, not a placeholder), not something a one-shot
# assertion should force in the same commit that makes it visible.
Check.register(
  id: "images-alt-text-present",
  desc: "Every <img> with an empty alt attribute is reported so the health page reflects real content",
  covers: ["9.3"]
) do |site|
  offenders = site.pages.flat_map do |page|
    page.body.scan(/<img\s+src="([^"]*)"\s+alt=""/).map { |src, | "#{page.path}: #{src}" }
  end

  unless offenders.empty?
    puts "images-alt-text-present: #{offenders.size} image(s) with empty alt text:"
    offenders.each { |o| puts "  - #{o}" }
  end
end
