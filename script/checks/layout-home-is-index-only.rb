# frozen_string_literal: true

Check.register(
  id: "layout-home-is-index-only",
  desc: "index.md is the only page declaring layout: home; every page declares a layout",
  covers: ["2.11"]
) do |site|
  site.pages.each do |page|
    layout = page.front_matter["layout"]

    site.fail!("#{page.path} declares no layout") if layout.nil?

    if layout == "home" && page.path != "index.md"
      site.fail!("#{page.path} declares layout: home but is not index.md")
    end
  end
end
