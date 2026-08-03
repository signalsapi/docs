# frozen_string_literal: true

Check.register(
  id: "openapi-lint-step-present",
  desc: "ci.yml declares a Spectral lint step whenever openapi/plane-v1.yaml exists",
  covers: ["10.2"]
) do |site|
  next unless File.exist?(File.join(ROOT, "openapi", "plane-v1.yaml"))

  ci_content = site.raw(".github/workflows/ci.yml")

  unless ci_content.downcase.include?("spectral")
    site.fail!("openapi/plane-v1.yaml exists but .github/workflows/ci.yml declares no Spectral step")
  end
end
