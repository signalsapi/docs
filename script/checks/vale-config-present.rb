# frozen_string_literal: true

Check.register(
  id: "vale-config-present",
  desc: ".vale.ini exists and its StylesPath resolves to an existing directory",
  covers: ["1.4"]
) do |site|
  site.fail!(".vale.ini is missing from the repository root") unless site.exist?(".vale.ini")

  styles_path = site.raw(".vale.ini")[/^\s*StylesPath\s*=\s*(\S+)/, 1]
  unless styles_path && site.dir?(styles_path)
    site.fail!(".vale.ini's StylesPath must resolve to an existing directory")
  end
end
