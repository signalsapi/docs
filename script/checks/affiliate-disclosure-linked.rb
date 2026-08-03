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
DISCLOSURE_CONTENT_REGION_RE = %r{<main\b[^>]*>(.*?)</main>}m.freeze

Check.register(
  id: "affiliate-disclosure-linked",
  desc: "Every page that emits an affiliate provider link also links to the commercial-relationship page",
  covers: ["9.8"]
) do |site|
  disclosure_path = "/how-we-make-money/"

  content = site.html_files.each_with_object({}) do |file, h|
    region = file.body[DISCLOSURE_CONTENT_REGION_RE, 1]
    if region.nil?
      site.fail!("#{file.path} renders no <main> element, so this assertion cannot tell what the page " \
                 "itself says from the chrome every page carries")
    end
    h[file.path] = region
  end

  # The pages that actually emit an affiliate link are the subject, not every
  # built page. provider-link.html's rel signature is the whole selector, so if
  # that markup changes the set empties silently and this passes having checked
  # no page (signalsapi-4324). The disclosure page is dropped before the count
  # on purpose: the rule has nothing to say about it, so a run in which it is
  # the only such page is a run that checked nothing.
  emitting = site.examining(
    "built pages emitting an affiliate provider link",
    site.html_files
        .select { |file| content[file.path].include?('rel="sponsored nofollow"') }
        .reject { |file| file.path.include?("how-we-make-money") } # the disclosure page itself
  )

  offenders = emitting.reject { |file| content[file.path].include?(%(href="#{disclosure_path}")) }.map(&:path)

  unless offenders.empty?
    site.fail!("page(s) emit an affiliate link without linking to #{disclosure_path} — #{offenders.join(', ')}")
  end
end
