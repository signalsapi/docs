# frozen_string_literal: true

# affiliate-links-disclosed (7.3) already guards that every affiliate link
# is disclosed AT the link itself. This guards the second half of Story
# 9.8: a page carrying one of those links also points a reader at the one
# page naming the whole commercial relationship, not just this one instance
# of it.
Check.register(
  id: "affiliate-disclosure-linked",
  desc: "Every page that emits an affiliate provider link also links to the commercial-relationship page",
  covers: ["9.8"]
) do |site|
  disclosure_path = "/how-we-make-money/"
  offenders = []

  site.html_files.each do |file|
    next unless file.body.include?('rel="sponsored nofollow"')
    next if file.path.include?("how-we-make-money") # the disclosure page itself

    offenders << file.path unless file.body.include?(%(href="#{disclosure_path}"))
  end

  unless offenders.empty?
    site.fail!("page(s) emit an affiliate link without linking to #{disclosure_path} — #{offenders.join(', ')}")
  end
end
