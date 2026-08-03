# frozen_string_literal: true

# The just-the-docs gem's own layouts invoke these two by name from inside the
# gem, so no file in this repository ever names them and their absence from the
# corpus is their correct state, not a dead partial. Every other file in
# _includes/ is ours, and ours earns its place by being invoked.
THEME_HOOK_INCLUDES = %w[head_custom.html footer_custom.html].freeze

# A partial nothing invokes is dead template code, and it takes any assertion
# written to guard it down with it: that guard scans every page, finds zero
# invocations, and passes on an empty offender set every run. The vacuity
# instrument (Story 1.12) cannot see this one, because such a guard does read
# the corpus through the Site model — it reports a full page count and looks
# healthy. So the invocation has to be asserted directly, on the partials
# themselves (signalsapi-4323, where term.html sat uninvoked from the day it
# was written and its guard passed 133 runs without ever having a subject).
Check.register(
  id: "every-include-is-invoked",
  desc: "Every partial in _includes/ is invoked by at least one page, theme hooks excepted"
) do |site|
  bodies = site.pages.map(&:body)

  partials = site.examining(
    "_includes/ partials",
    site.glob("_includes/*.html").map { |path| File.basename(path) } - THEME_HOOK_INCLUDES
  )

  orphans = partials.reject do |name|
    invocation = /\{%-?\s*include\s+#{Regexp.escape(name)}(?![\w.-])/
    bodies.any? { |body| body.match?(invocation) }
  end

  unless orphans.empty?
    site.fail!(
      "partial(s) in _includes/ that no page invokes: #{orphans.join(', ')} — " \
      "wire each into a page or retire it, because an uninvoked partial is dead " \
      "template code and any assertion guarding it has nothing to check"
    )
  end
end
