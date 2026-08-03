# frozen_string_literal: true

# Story 11.10 retired the changelog's 53 decorative screenshots (1.9 MB,
# the bulk of the repository's image payload) and gave every surviving one
# a declared width and height — computed from its own intrinsic pixel
# dimensions in _data/screenshots.yml — so the browser reserves the right
# space before the image loads instead of shifting the page underneath a
# reader. This reads the BUILT site and fails if any <img> element omits
# either attribute.
Check.register(
  id: "image-dimensions-declared",
  desc: "every built <img> element declares both width and height",
  covers: ["11.10"]
) do |site|
  offenders = []

  site.html_files.each do |file|
    file.body.scan(/<img\s+[^>]*>/).each do |tag|
      src_m = tag.match(/src="([^"]*)"/)
      src = src_m ? src_m[1] : "(unknown src)"

      missing = []
      missing << "width" unless tag.include?("width=")
      missing << "height" unless tag.include?("height=")

      offenders << "#{file.path}: #{src} is missing #{missing.join(' and ')}" unless missing.empty?
    end
  end

  site.fail!("image(s) with undeclared dimensions — #{offenders.join('; ')}") unless offenders.empty?
end
