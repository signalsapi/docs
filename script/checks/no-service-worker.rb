# frozen_string_literal: true

# Story 10.3 answers "the docs are the sandbox" with real static files
# (fixtures-match-spec.rb) instead of a service worker faking the network —
# a demo that only works because JS intercepted fetch() would pass in a
# browser and fail the moment the same printed curl command runs in a
# terminal. This guards against that shortcut creeping back in later.
Check.register(
  id: "no-service-worker",
  desc: "no committed JavaScript file registers a service worker",
  covers: ["10.3"]
) do |site|
  offenders = site.glob("**/*.js")
                  .reject { |f| f.start_with?(*Site::CONTENT_EXCLUDED_DIRS.map { |d| "#{d}/" }) }
                  .reject { |f| f.include?("/node_modules/") }
                  .select { |f| site.raw(f).include?("serviceWorker.register") }

  site.fail!("JavaScript file(s) register a service worker — #{offenders.join(', ')}") unless offenders.empty?
end
