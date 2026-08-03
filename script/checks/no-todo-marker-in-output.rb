# frozen_string_literal: true

# The TODO(owner:) grammar (Story 1.9) is an internal ledger of figures we
# refuse to invent — it is not copy. Five built surfaces were publishing it
# verbatim (/pricing, /faq, the provider comparison, llms-full.txt and the
# search index) because a Liquid tag renders whatever the data file holds.
# A marker in _data/ is correct; a marker on the live site is a defect, so
# this asserts the boundary the render layer has to respect: templates show
# a plain "not published yet" line instead, via _includes/pricing-figure.html.
Check.register(
  id: "no-todo-marker-in-output",
  desc: "No built page under _site/ publishes an owner-marked figure placeholder",
  covers: ["1.9"]
) do |site|
  site_dir = File.join(ROOT, "_site")
  next unless Dir.exist?(site_dir)

  offenders = Dir.glob(File.join(site_dir, "**", "*")).select do |path|
    File.file?(path) && File.read(path).include?("TODO(owner:")
  end

  unless offenders.empty?
    rels = offenders.map { |p| p.sub("#{ROOT}/", "") }.sort
    site.fail!("TODO(owner:) marker published in: #{rels.join(', ')}")
  end
end
