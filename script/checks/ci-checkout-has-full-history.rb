# frozen_string_literal: true

# Story 1.10: no-page-deleted-without-redirect reads the pre-overhaul baseline
# tree with `git ls-tree ddc51a8`. actions/checkout defaults to a depth-1 clone,
# which has no such commit — the command returned nothing and the assertion
# failed on an empty baseline rather than on a real regression. Any assertion
# that reads history needs the history to be there.
Check.register(
  id: "ci-checkout-has-full-history",
  desc: ".github/workflows/ci.yml checks out full history, which the baseline-commit assertions read",
  covers: ["1.10"]
) do |site|
  ci = site.raw(".github/workflows/ci.yml")

  unless ci.lines.any? { |line| line.strip == "fetch-depth: 0" }
    site.fail!(".github/workflows/ci.yml must check out with `fetch-depth: 0` — " \
               "no-page-deleted-without-redirect reads a commit a shallow clone does not carry")
  end
end
