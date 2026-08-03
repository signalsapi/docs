# frozen_string_literal: true

Check.register(
  id: "vale-version-pinned",
  desc: ".vale-version records a real Vale version, not the literal word 'latest'",
  covers: ["1.5"]
) do |site|
  version_path = File.join(ROOT, ".vale-version")
  version = File.exist?(version_path) ? File.read(version_path).strip : nil

  if version.nil? || version.empty? || version == "latest"
    site.fail!(".vale-version must record a real Vale version, not be missing or 'latest'")
  end
end
