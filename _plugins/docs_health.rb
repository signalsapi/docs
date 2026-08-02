# frozen_string_literal: true

require "set"

# Story 9.3: docs-health.md's tables are computed fresh every build from
# the same corpus every script/checks/*.rb assertion reads — a metric
# published here without a registered assertion behind it would just be
# an unverified claim, which is exactly what docs-health-rows-match-
# registry (script/checks/docs-health-rows-match-registry.rb) prevents.
module SignalsapiDocs
  class DocsHealthGenerator < Jekyll::Generator
    STALENESS_THRESHOLD_DAYS = 90
    # (?<!!) on the OPENING bracket excludes markdown image embeds
    # (![alt](url)) — those reference an asset, not a page, so they're
    # never a candidate "internal link". A lookbehind on the closing
    # bracket wouldn't catch ![](url): its "]" is preceded by "[", not "!".
    INTERNAL_LINK_RE = /(?<!!)\[[^\]]*\]\(((?:\.\.\/|\/)[^)]*)\)/.freeze

    def generate(site)
      pages = site.pages.select { |p| p.data["page_type"] }
      raw_bodies = pages.to_h { |p| [p, File.read(File.join(site.source, p.relative_path))] }

      site.data["docs_health"] = {
        "missing_description" => missing_description(pages),
        "empty_alt_images" => empty_alt_images(pages, raw_bodies),
        "broken_internal_links" => broken_internal_links(pages, raw_bodies),
        "stale_pages" => stale_pages(pages),
        "orphan_pages" => orphan_pages(pages, raw_bodies)
      }
    end

    private

    def missing_description(pages)
      pages.select { |p| p.data["description"].to_s.strip.empty? }
           .map { |p| { "path" => p.relative_path, "title" => p.data["title"] } }
    end

    def empty_alt_images(pages, raw_bodies)
      pages.flat_map do |p|
        raw_bodies[p].scan(/<img\s+src="([^"]*)"\s+alt=""/).map do |src, |
          { "path" => p.relative_path, "title" => p.data["title"], "image" => src }
        end
      end
    end

    def broken_internal_links(pages, raw_bodies)
      known_urls = pages.map(&:url).to_set
      pages.flat_map do |p|
        raw_bodies[p].scan(INTERNAL_LINK_RE).flatten.uniq.filter_map do |link|
          target = resolve_link(link, p.url)
          next if known_urls.include?(target)

          { "path" => p.relative_path, "title" => p.data["title"], "link" => link }
        end
      end
    end

    def stale_pages(pages)
      today = Date.today
      pages.filter_map do |p|
        verified_on = p.data["verified_on"]
        next unless verified_on.is_a?(Date)

        age = (today - verified_on).to_i
        next unless age > STALENESS_THRESHOLD_DAYS

        { "path" => p.relative_path, "title" => p.data["title"], "verified_on" => verified_on.to_s, "days" => age }
      end
    end

    def orphan_pages(pages, raw_bodies)
      inbound = Hash.new(0)
      pages.each do |p|
        raw_bodies[p].scan(INTERNAL_LINK_RE).flatten.each do |link|
          inbound[resolve_link(link, p.url)] += 1
        end
      end

      pages.reject { |p| p.data["page_type"] == "router" }
           .select { |p| inbound[p.url].zero? }
           .map { |p| { "path" => p.relative_path, "title" => p.data["title"] } }
    end

    # A link's own href is resolved relative to the linking page's URL, the
    # same way a browser would — "../x/" from "/features/y/" means
    # "/features/x/", not "/x/". File.expand_path always strips a trailing
    # slash, so it has to be added back for every target that isn't a file
    # (pretty-permalink page URLs all end in "/").
    def resolve_link(link, from_url)
      target = link.split("#").first
      resolved = File.expand_path(target, from_url)
      resolved += "/" unless resolved.include?(".") || resolved.end_with?("/")
      resolved
    end
  end
end
