# frozen_string_literal: true

Check.register(
  id: "og-image-per-page",
  desc: "Every built page's og:image resolves to a card file that exists in the built site",
  covers: ["8.7"]
) do |site|
  base_url = YAML.safe_load(site.raw("_config.yml"))["url"]
  offenders = []

  site.html_files.each do |file|
    match = file.body.match(/<meta property="og:image" content="([^"]*)"/)

    unless match
      offenders << "#{file.path}: no og:image tag"
      next
    end

    url = match[1]
    unless url.start_with?(base_url)
      offenders << "#{file.path}: og:image #{url} is not an absolute URL under #{base_url}"
      next
    end

    relative = url.sub(base_url, "")
    card_path = File.join(ROOT, "_site", relative)
    offenders << "#{file.path}: og:image points at a file absent from the built site — #{relative}" unless File.exist?(card_path)
  end

  site.fail!("og:image violation(s) — #{offenders.join('; ')}") unless offenders.empty?
end
