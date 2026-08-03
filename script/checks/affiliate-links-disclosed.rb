# frozen_string_literal: true

# Story 7.3: _includes/provider-link.html is the only mechanism allowed to
# emit a provider URL. Its own output always carries class="provider-link",
# and rel="sponsored nofollow" whenever the provider is an affiliate — so
# any affiliate-tracked anchor missing either signature was hand-written
# outside the include.
AFFILIATE_PARAM_RE = /\?(?:via|fp_ref)=signalsapi/.freeze

Check.register(
  id: "affiliate-links-disclosed",
  desc: "Every built anchor with an affiliate tracking parameter was emitted by provider-link.html and discloses the relationship",
  covers: ["7.3"]
) do |site|
  # The tracked anchors are the subject, not the built pages they sit on. Every
  # one of them comes from _data/providers.yml through provider-link.html, so a
  # provider switching to a tracking parameter this pattern does not name — or
  # an anchor the pattern stops matching — empties the set, and the assertion
  # then passes having inspected no link at all while still reporting a full
  # page count (signalsapi-4324).
  tracked = site.examining(
    "built anchors carrying an affiliate tracking parameter",
    site.html_files.flat_map do |file|
      file.body.scan(/<a\s([^>]*)>/i).flatten.filter_map { |tag_attrs|
        href = tag_attrs[/href="([^"]*)"/, 1]
        [file.path, href, tag_attrs] if href&.match?(AFFILIATE_PARAM_RE)
      }
    end
  )

  offenders = tracked.filter_map do |path, href, tag_attrs|
    disclosed = tag_attrs.include?('rel="sponsored nofollow"') && tag_attrs.include?('class="provider-link"')
    "#{path}: #{href}" unless disclosed
  end

  site.fail!("undisclosed affiliate link(s) — #{offenders.uniq.join(', ')}") unless offenders.empty?
end
