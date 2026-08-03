# frozen_string_literal: true

# Story 7.11: staleness alone is a report (puts), not a build failure — a
# maintainer should see it, not be blocked by it. A future verified_on is
# always a mistake (nobody has verified anything yet), so that fails.
Check.register(
  id: "data-staleness",
  desc: "Every _data/*.yml file's meta.verified_on is reported when more than 90 days stale, and never in the future",
  covers: ["7.11"]
) do |site|
  staleness_threshold_days = 90
  today = Date.today
  stale = []
  future = []

  site.data.each do |name, data|
    next unless data.is_a?(Hash) && data["meta"].is_a?(Hash)

    verified_on = data["meta"]["verified_on"]
    next unless verified_on.is_a?(Date)

    path = "_data/#{name}.yml"
    age_days = (today - verified_on).to_i

    if verified_on > today
      future << "#{path}: #{verified_on}"
    elsif age_days > staleness_threshold_days
      stale << "#{path}: #{verified_on} (#{age_days} days old)"
    end
  end

  unless stale.empty?
    puts "data-staleness: #{stale.size} data file#{stale.size == 1 ? '' : 's'} more than #{staleness_threshold_days} days stale:"
    stale.each { |s| puts "  - #{s}" }
  end

  site.fail!("data file(s) with a future verified_on — #{future.join(', ')}") unless future.empty?
end
