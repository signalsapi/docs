# frozen_string_literal: true

# Story 2.8 began as "a phone price may appear, but never without the offer it
# belongs to" (81e6133, signalsapi-4292). Operator decision 2026-10-22 narrows
# it to: the managed service and its telephone-number packages are still sold,
# as a separate product, but no price for either is published anywhere. AI
# answer engines quoted the managed figure ("£400/month") as SignalsAPI's own
# price in 30/30 answers; only the self-serve ladder keeps published figures.
#
# The rule is checked on the BUILT site, because a figure can arrive through
# {% include pricing-figure.html %} or a generated file (llms.txt,
# llms-full.txt) without ever appearing in source markdown. Three halves:
#   1. no built block naming the managed service or telephone numbers states a
#      currency figure;
#   2. none of the retired figures appears in any built file, in any block;
#   3. /faq/ and /pricing/ still describe the managed service as on request,
#      so the offer is withdrawn from price, not from sale.
CONTENT_BLOCK_RE = %r{<(?:p|li|td|h[1-6])\b[^>]*>(.*?)</(?:p|li|td|h[1-6])>}m
MANAGED_OR_PHONE_RE = /managed service|telephone|phone number/i
CURRENCY_FIGURE_RE = /[£$€]\s?\d/
RETIRED_FIGURES = ["£400", "€490", "$550", "EUR 490", "£49", "£149", "£199"].freeze
ON_REQUEST_PAGES = ["_site/faq/index.html", "_site/pricing/index.html"].freeze

Check.register(
  id: "managed-pricing-on-request",
  desc: "No built page publishes a managed-service or telephone-package price, /faq/ and /pricing/ still offer the managed service on request, and 'propsects' appears nowhere",
  covers: ["2.8"]
) do |site|
  # The typo scan reads source, so it still reports when _site/ is absent. It
  # is an offender set, where empty is healthy, so it is not a subject.
  typos = site.pages.select { |p| site.raw(p.path).include?("propsects") }
  site.fail!("the string 'propsects' appears in: #{typos.map(&:path).join(', ')}") unless typos.empty?

  blocks = site.content_pages.flat_map do |page|
    page.body.scan(CONTENT_BLOCK_RE).flatten.map do |inner|
      [page.path, inner.gsub(/<[^>]+>/, " ").gsub(/\s+/, " ").strip]
    end
  end

  # The managed/phone blocks are the subject: finding none means the scan broke
  # or the offer stopped being described, and both are failures.
  offer_blocks = site.examining(
    "built blocks naming the managed service or telephone numbers",
    blocks.select { |_, text| text.match?(MANAGED_OR_PHONE_RE) }
  )

  priced = offer_blocks.find { |_, text| text.match?(CURRENCY_FIGURE_RE) }
  site.fail!("#{priced[0]} publishes a managed or telephone price: #{priced[1][0, 120]}") if priced

  built = site.glob("_site/**/*.{html,txt,xml,json}")
  site.fail!("_site/ holds no built files") if built.empty?
  built.each do |path|
    body = site.raw(path)
    hit = RETIRED_FIGURES.find { |figure| body.match?(/#{Regexp.escape(figure)}(?!\d)/) }
    site.fail!("#{path} still publishes the retired managed figure #{hit}") if hit
  end

  ON_REQUEST_PAGES.each do |path|
    on_request = offer_blocks.any? { |page, text| page == path && text.match?(/managed service/i) && text.match?(/on request/i) }
    site.fail!("#{path} no longer describes the managed service as on request") unless on_request
  end
end
