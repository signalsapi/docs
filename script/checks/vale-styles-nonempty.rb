# frozen_string_literal: true

Check.register(
  id: "vale-styles-nonempty",
  desc: "styles/SignalsAPI/ contains at least one Vale rule file",
  covers: ["1.4"]
) do |site|
  rule_files = Dir.glob(File.join(ROOT, "styles", "SignalsAPI", "*.yml"))

  site.fail!("styles/SignalsAPI/ must contain at least one rule file") if rule_files.empty?
end
