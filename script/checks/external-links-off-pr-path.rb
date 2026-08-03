# frozen_string_literal: true

# AD-10: external links never gate a pull request. html-proofer runs with
# external checking disabled inside rake check; a scheduled workflow sweeps
# the external set separately and never runs on the pull_request path.
Check.register(
  id: "external-links-off-pr-path",
  desc: "html-proofer runs --disable-external in the Rakefile, and the nightly lychee workflow never triggers on pull_request",
  covers: ["1.13"]
) do |site|
  unless site.raw("Rakefile").include?("--disable-external")
    site.fail!("Rakefile's html-proofer invocation must include --disable-external (AD-10)")
  end

  nightly = Dir.glob(File.join(ROOT, ".github", "workflows", "*.yml")).find { |f| File.read(f).include?("lychee") }
  site.fail!("no .github/workflows/*.yml file runs lychee for the nightly external-link sweep") unless nightly

  rel_path = nightly.sub("#{ROOT}/", "")
  site.fail!("#{rel_path} must not trigger on pull_request (AD-10)") if File.read(nightly).include?("pull_request")
end
