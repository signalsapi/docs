# frozen_string_literal: true

# Story 9.4: staleness alone is a report, not a build failure (a maintainer
# should see it, not be blocked by it) — but a missing verified_on entirely
# fails outright, so the stamp can't be silently dropped to dodge this.
# verified-on-present (9.1) already enforces this too; this repeats the
# guard so page-staleness genuinely satisfies 9.4's own AC on its own.
Check.register(
  id: "page-staleness",
  desc: "Every page's verified_on more than 90 days old is reported; a page with no verified_on fails outright",
  covers: %w[9.3 9.4]
) do |site|
  staleness_threshold_days = 90
  today = Date.today
  stale = []
  missing = []

  site.pages.each do |page|
    verified_on = page.front_matter["verified_on"]
    if verified_on.nil?
      missing << page.path
      next
    end
    next unless verified_on.is_a?(Date)

    age_days = (today - verified_on).to_i
    stale << "#{page.path}: #{verified_on} (#{age_days} days old)" if age_days > staleness_threshold_days
  end

  unless stale.empty?
    puts "page-staleness: #{stale.size} page#{stale.size == 1 ? '' : 's'} more than #{staleness_threshold_days} days stale:"
    stale.each { |s| puts "  - #{s}" }
  end

  site.fail!("page(s) with no verified_on at all — #{missing.join(', ')}") unless missing.empty?
end
