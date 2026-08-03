# frozen_string_literal: true

# Story 11.3 replaced nine GitBook-era instructional screenshots with a click
# path and a field table generated from _data/controls.yml — this is the
# regression guard should one of them come back instead of the data file
# being extended.
DELETED_INSTRUCTIONAL_IMAGES = [
  "features/do-not-contact-list.png",
  "features/filter-leads-with-ai.png",
  "features/find-decision-makers-1.png",
  "features/find-decision-makers-2.png",
  "features/personalize-emails-with-ai-1.png",
  "features/personalize-emails-with-ai-2.png",
  "features/personalize-emails-with-ai-3.png",
  "features/remove-duplicate-signals-1.png",
  "features/remove-duplicate-signals-2.png"
].freeze

Check.register(
  id: "no-instructional-images-remain",
  desc: "none of the nine GitBook-era instructional screenshots Story 11.3 replaced with text comes back",
  covers: ["11.3"]
) do |site|
  restored = DELETED_INSTRUCTIONAL_IMAGES.select { |path| site.exist?(path) }
  site.fail!("instructional image(s) that should stay deleted are back — #{restored.join(', ')}") unless restored.empty?
end
