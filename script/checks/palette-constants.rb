# frozen_string_literal: true

Check.register(
  id: "palette-constants",
  desc: "The hex values in _sass/color_schemes/signalsapi.scss match the fourteen declared in DESIGN.md",
  covers: ["2.15"]
) do |site|
  front_matter = site.raw("DESIGN.md")[/\A---\n(.*?)\n---/m, 1]
  design_colors = YAML.safe_load(front_matter)["colors"].values.map(&:downcase).sort

  scss_colors = site.raw("_sass/color_schemes/signalsapi.scss")
                     .scan(/:\s*(#[0-9a-fA-F]{6})\s*;/)
                     .flatten
                     .map(&:downcase)
                     .sort

  if scss_colors != design_colors
    site.fail!("palette drift: signalsapi.scss declares #{scss_colors} but DESIGN.md declares #{design_colors}")
  end
end
