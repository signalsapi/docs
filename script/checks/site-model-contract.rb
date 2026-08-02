# frozen_string_literal: true

Check.register(
  id: "site-model-contract",
  desc: "site.pages, site.html_files, site.data and site.raw(path) are all present and non-nil",
  covers: ["1.7"]
) do |site|
  site.fail!("site.pages is nil or empty for a repository with at least one page") if site.pages.nil? || site.pages.empty?
  site.fail!("site.html_files is nil") if site.html_files.nil?
  site.fail!("site.data is nil") if site.data.nil?
  site.fail!("site.raw(path) returned nil for _config.yml") if site.raw("_config.yml").nil?
end
