# frozen_string_literal: true

# Reported, not failed — an old screenshot might still be accurate (the
# do-not-contact-list panel probably hasn't changed shape), and re-verifying
# each one is real content work, not something a one-shot assertion should
# force. This exists so the health page can surface the list, the same way
# page-staleness.rb does for pages.
Check.register(
  id: "screenshot-age",
  desc: "Every image whose capture_date is more than 180 days old is listed in the run summary",
  covers: ["11.4"]
) do |site|
  staleness_threshold_days = 180
  items = site.data.dig("screenshots", "items") || []
  today = Date.today

  old = items.select do |i|
    date = i["capture_date"]
    date.is_a?(Date) && (today - date).to_i > staleness_threshold_days
  end

  unless old.empty?
    puts "screenshot-age: #{old.size} image#{old.size == 1 ? '' : 's'} more than #{staleness_threshold_days} days old:"
    old.sort_by { |i| i["capture_date"] }.each do |i|
      puts "  - #{i['path']}: #{i['capture_date']} (#{(today - i['capture_date']).to_i} days old)"
    end
  end
end
