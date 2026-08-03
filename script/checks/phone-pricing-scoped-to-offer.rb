# frozen_string_literal: true

# Story 2.8's rule was never "no phone price on the FAQ". 81e6133 added it
# because faq.md sold telephone numbers at package tiers while
# features/find-phone-numbers.md documented a bring-your-own-provider model —
# an *unscoped* price is what made the two pages contradict each other. Merge
# 16336568 then settled that contradiction from the other side: both answers
# are true, of different offers, so the FAQ now names both and renders the
# package figures from _data/pricing.yml.
#
# What survives is therefore a narrower rule: a phone price may appear, but
# never without the offer it belongs to. And it has to be checked on the BUILT
# page, because {% include pricing-figure.html %} means the figure is no longer
# in the source markdown the original assertion scanned — it read faq.md and so
# stayed green while /faq/ published "£49/month for 100 telephone numbers"
# (signalsapi-4292). currency-outside-data and pricing-page-renders-from-data
# still read the source on purpose: their subject IS the source file.
PHONE_PRICE_BLOCK_RE = %r{<(?:p|li|td)\b[^>]*>(.*?)</(?:p|li|td)>}m
MANAGED_OFFER_RE = /managed service/i

Check.register(
  id: "phone-pricing-scoped-to-offer",
  desc: "No block of the built /faq/ page states a phone-number price without naming the managed service it belongs to, and 'propsects' appears nowhere",
  covers: ["2.8"]
) do |site|
  # The typo scan runs first and reads source, so it still reports when _site/
  # is absent — only the rendered half below depends on a build. It is an
  # offender set ("this string appears nowhere"), where empty is the healthy
  # state, so it is deliberately not declared as a subject.
  typos = site.pages.select { |p| site.raw(p.path).include?("propsects") }
  site.fail!("the string 'propsects' appears in: #{typos.map(&:path).join(', ')}") unless typos.empty?

  faq = site.html_files.find { |f| f.path == "_site/faq/index.html" }
  site.fail!("_site/faq/index.html is missing") unless faq

  # The priced blocks are the subject; the page is only where they live. Finding
  # none is exactly the state that produced signalsapi-4292 — the source scan
  # this replaced matched nothing and passed while /faq/ published the figure —
  # and the rendered form is just as breakable: an escaped currency symbol, or a
  # figure that moves out of p/li/td, empties the set the same silent way. The
  # figure is data-driven (pricing.yml's managed_phone_packages, via
  # pricing-figure.html), so an empty set means either the scan broke or the
  # offer was retired. Both are worth a look; neither is a clean run.
  priced = site.examining(
    "built /faq/ blocks stating a phone price",
    faq.body.scan(PHONE_PRICE_BLOCK_RE).flatten.filter_map { |inner|
      text = inner.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip
      text if text.match?(/phone/i) && text.match?(/[£$€]\s?\d/)
    }
  )

  unscoped = priced.reject { |text| text.match?(MANAGED_OFFER_RE) }

  unless unscoped.empty?
    site.fail!("the built /faq/ prices a phone number without naming the offer it belongs to: #{unscoped.first[0, 120]}")
  end
end
