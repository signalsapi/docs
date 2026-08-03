# frozen_string_literal: true

Check.register(
  id: "ci-runs-rake-check",
  desc: ".github/workflows/ci.yml contains a step whose run command is exactly `bundle exec rake check`",
  covers: ["1.10"]
) do |site|
  ci = site.raw(".github/workflows/ci.yml")

  unless ci.lines.any? { |line| line.strip == "run: bundle exec rake check" }
    site.fail!(".github/workflows/ci.yml must contain a step with `run: bundle exec rake check`")
  end
end
