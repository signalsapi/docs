# frozen_string_literal: true

# affiliate-links-disclosed (7.3) already guards that every affiliate link
# is disclosed AT the link itself. This guards the second half of Story
# 9.8: a page carrying one of those links also points a reader at the one
# page naming the whole commercial relationship, not just this one instance
# of it.
#
# Both halves read the page's own content region rather than its whole body.
# just-the-docs renders "How we make money" into the site nav, which every
# built page carries, so a whole-body search for the disclosure link matched
# all 58 pages and this assertion could not fail whatever a page actually
# said. Found while declaring its subject (signalsapi-4324): the vacuity
# instrument cannot see this one — the subject set is non-empty and the pages
# really are read, it is the predicate that was always true.
#
# The region itself is site.content_pages rather than a regexp of this check's
# own: no-instruction-only-in-image turned out to have the same hole
# (signalsapi-4327), and a second copy is how a third one gets written.
Check.register(
  id: "affiliate-disclosure-linked",
  desc: "Every page that emits an affiliate provider link also links to the commercial-relationship page",
  covers: ["9.8"]
) do |site|
  disclosure_path = "/how-we-make-money/"

  # The pages that actually emit an affiliate link are the subject, not every
  # built page. provider-link.html's rel signature is the whole selector, so if
  # that markup changes the set empties silently and this passes having checked
  # no page (signalsapi-4324). The disclosure page is dropped before the count
  # on purpose: the rule has nothing to say about it, so a run in which it is
  # the only such page is a run that checked nothing.
  emitting = site.examining(
    "built pages emitting an affiliate provider link",
    site.content_pages
        .select { |page| page.body.include?('rel="sponsored nofollow"') }
        .reject { |page| page.path.include?("how-we-make-money") } # the disclosure page itself
  )

  offenders = emitting.reject { |page| page.body.include?(%(href="#{disclosure_path}")) }.map(&:path)

  unless offenders.empty?
    site.fail!("page(s) emit an affiliate link without linking to #{disclosure_path} — #{offenders.join(', ')}")
  end
end
