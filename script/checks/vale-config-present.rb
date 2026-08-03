# frozen_string_literal: true

Check.register(
  id: "vale-config-present",
  desc: ".vale.ini exists and its StylesPath resolves to an existing directory",
  covers: ["1.4"]
) do |site|
  config_path = File.join(ROOT, ".vale.ini")
  site.fail!(".vale.ini is missing from the repository root") unless File.exist?(config_path)

  styles_path = File.read(config_path)[/^\s*StylesPath\s*=\s*(\S+)/, 1]
  unless styles_path && File.directory?(File.join(ROOT, styles_path))
    site.fail!(".vale.ini's StylesPath must resolve to an existing directory")
  end
end
