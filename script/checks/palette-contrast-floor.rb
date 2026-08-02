# frozen_string_literal: true

# WCAG 2.x relative luminance / contrast ratio, computed in plain Ruby —
# deliberately not pa11y-ci or axe (DESIGN.md § Colors): no headless browser,
# no node toolchain, no nondeterminism.
Check.register(
  id: "palette-contrast-floor",
  desc: "DESIGN.md's declared text-on-background pairing meets the WCAG 4.5:1 contrast floor",
  covers: ["2.15"]
) do |site|
  scss = site.raw("_sass/color_schemes/signalsapi.scss")
  text_hex = scss[/\$tx:\s*(#[0-9a-fA-F]{6})/, 1]
  bg_hex = scss[/\$bg:\s*(#[0-9a-fA-F]{6})/, 1]

  relative_luminance = lambda do |hex|
    r, g, b = [hex[1, 2], hex[3, 2], hex[5, 2]].map { |c| c.to_i(16) / 255.0 }
    r, g, b = [r, g, b].map { |c| c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055)**2.4 }
    (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
  end

  l_text = relative_luminance.call(text_hex)
  l_bg = relative_luminance.call(bg_hex)
  lighter, darker = [l_text, l_bg].max, [l_text, l_bg].min
  ratio = (lighter + 0.05) / (darker + 0.05)

  if ratio < 4.5
    site.fail!("text (#{text_hex}) on bg (#{bg_hex}) contrast ratio #{ratio.round(2)}:1 is below the 4.5:1 floor")
  end
end
