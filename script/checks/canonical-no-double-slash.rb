# frozen_string_literal: true

Check.register(
  id: "canonical-no-double-slash",
  desc: "No file under _site/ contains docs.signalsapi.com//",
  covers: ["2.1", "FR6"]
) do |site|
  site.html_files.each do |f|
    site.fail!("#{f.path} contains a double-slashed canonical") if f.body.include?("docs.signalsapi.com//")
  end
end
