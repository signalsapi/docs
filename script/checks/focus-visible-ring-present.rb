# frozen_string_literal: true

Check.register(
  id: "focus-visible-ring-present",
  desc: "custom.scss never sets outline: none on a :focus rule without a paired :focus-visible rule",
  covers: ["2.13"]
) do |site|
  # Strip // comments first — they can legitimately mention ":focus-visible"
  # descriptively, which must not satisfy the pairing check below.
  content = site.raw("_sass/custom/custom.scss").gsub(%r{//[^\n]*}, "")

  bare_focus_none = content.scan(/:focus(?!-visible)[^{]*\{[^}]*outline:\s*none[^}]*\}/m)

  if bare_focus_none.any? && !content.include?(":focus-visible")
    site.fail!("custom.scss sets outline: none on a :focus rule with no paired :focus-visible rule")
  end
end
