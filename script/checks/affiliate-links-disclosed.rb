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
  offenders = []

  site.html_files.each do |file|
    file.body.scan(/<a\s([^>]*)>/i) do |match|
      tag_attrs = match.first
      href = tag_attrs[/href="([^"]*)"/, 1]
      next unless href&.match?(AFFILIATE_PARAM_RE)

      disclosed = tag_attrs.include?('rel="sponsored nofollow"') && tag_attrs.include?('class="provider-link"')
      offenders << "#{file.path}: #{href}" unless disclosed
    end
  end

  site.fail!("undisclosed affiliate link(s) — #{offenders.uniq.join(', ')}") unless offenders.empty?
end
