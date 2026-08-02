# frozen_string_literal: true

Check.register(
  id: "one-canonical-per-page",
  desc: "Every built HTML file contains exactly one rel=\"canonical\" element",
  covers: ["2.14"]
) do |site|
  offenders = site.html_files.map { |f| [f, f.body.scan(/rel="canonical"/).size] }
                              .reject { |_f, count| count == 1 }

  unless offenders.empty?
    details = offenders.map { |f, count| "#{f.path} (#{count})" }.join(", ")
    site.fail!("expected exactly one rel=\"canonical\" per page: #{details}")
  end
end
