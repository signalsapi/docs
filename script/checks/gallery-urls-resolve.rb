# frozen_string_literal: true

# The gallery's whole premise (Story 10.4) is that a printed command and the
# artifact next to it cannot disagree — so this reads the built page (not the
# source) and resolves every absolute URL it prints against this origin
# (_config.yml's url:) to a real file in _site/, the same way a terminal
# pasting the command would resolve it against the live origin.
Check.register(
  id: "gallery-urls-resolve",
  desc: "every absolute URL printed in the fixture gallery's commands exists in the built site",
  covers: ["10.4"]
) do |site|
  site_url = YAML.safe_load(site.raw("_config.yml"))["url"]
  site.fail!("_config.yml has no url:") unless site_url

  gallery = site.html_files.find { |f| f.path == "_site/features/agent-data-plane-fixtures/index.html" }
  next unless gallery

  commands = gallery.body.scan(%r{curl #{Regexp.escape(site_url)}(/\S*)})
  site.fail!("gallery has no curl command targeting #{site_url}") if commands.empty?

  missing = commands.flatten.uniq.reject { |path| site.exist?("_site#{path}") }
  unless missing.empty?
    site.fail!("gallery command(s) target a URL absent from _site/ — #{missing.map { |p| "#{site_url}#{p}" }.join(', ')}")
  end
end
