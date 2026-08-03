# frozen_string_literal: true

require "rake"
require "yaml"
require "date"

# Directories that hold no publishable documentation prose: build output,
# drafts (NFR10), and the various planning/tooling scaffolds this repo
# happens to carry. Vale would otherwise choke trying to parse their front
# matter, or lint prose that was never meant to ship.
VALE_EXCLUDED_DIRS = %w[_site _drafts .claude .github .ralph .jekyll-cache _bmad _bmad-output bmalph].freeze

# AD-12: Vale is provisioned the same way locally and in CI, from this one
# file (.github/workflows/ci.yml reads it too), so a prose failure reproduces
# on a contributor's machine instead of only in CI.
VALE_VERSION = File.read(File.join(File.dirname(__FILE__), ".vale-version")).strip

def vale_on_path?
  ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).any? { |dir| File.executable?(File.join(dir, "vale")) }
end

# Story 10.2: Spectral is provisioned the same way — a pinned version this
# file and .github/workflows/ci.yml both read — so a spec regression
# reproduces on a contributor's machine instead of only in CI.
SPECTRAL_VERSION = File.read(File.join(File.dirname(__FILE__), ".spectral-version")).strip

# The CLI pin above does not pin the rules it enforces: @stoplight/spectral-cli
# declares "@stoplight/spectral-rulesets": ">=1", so spectral:oas floats to
# whatever npm resolves at install time. On 2026-08-03 the same pinned CLI
# 6.16.2 aborted this lint under rulesets 1.22.6 and passed under 1.22.7.
# Pinning both is what makes the promise in the comment above true.
SPECTRAL_RULESET_VERSION = File.read(File.join(File.dirname(__FILE__), ".spectral-ruleset-version")).strip

def spectral_on_path?
  ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).any? { |dir| File.executable?(File.join(dir, "spectral")) }
end

namespace :check do
  desc "Build the Jekyll site into _site/"
  task :build do
    sh "bundle exec jekyll build"
  end

  desc "Run html-proofer against the built site (external checking disabled)"
  task :links do
    # Story 8.8: jekyll-redirect-from writes each old GitBook-era path as a
    # flat "name.html" stub next to the pretty-permalink "name/" directory
    # it now redirects to. html-proofer's default --assume-extension tries
    # "name.html" before falling back to "name/index.html", so it silently
    # checks anchors against the redirect stub instead of the real page.
    # Every internal link here already uses an explicit trailing slash, so
    # the extension-guessing fallback buys nothing and only misresolves.
    sh 'bundle exec htmlproofer _site --disable-external --assume-extension ""'
  end

  desc "Run Vale against every .md file outside _site/ and _drafts/"
  task :prose do
    unless vale_on_path?
      abort(<<~MSG)
        rake check:prose: the vale binary (pinned version #{VALE_VERSION}) is not on PATH.
        Install it with:
          brew install vale   # macOS
        or download the pinned release directly (same binary CI installs):
          https://github.com/errata-ai/vale/releases/tag/v#{VALE_VERSION}
        Then confirm `vale --version` reports #{VALE_VERSION}.
      MSG
    end

    sh "vale --glob='!{#{VALE_EXCLUDED_DIRS.join(',')}}/**' ."
  end

  desc "Run script/check.rb assertions against the site (all, or just [id] against the already-built _site/)"
  task :assert, [:id] do |_t, args|
    sh args[:id] ? "ruby script/check.rb #{args[:id]}" : "ruby script/check.rb"
  end

  desc "Scaffold script/checks/[id].rb from a template with a failing body"
  task :new, [:id] do |_t, args|
    id = args[:id]
    abort("usage: rake check:new[my-assertion-id]") unless id

    path = File.join(File.dirname(__FILE__), "script", "checks", "#{id}.rb")
    abort("script/checks/#{id}.rb already exists") if File.exist?(path)

    File.write(path, <<~RUBY)
      # frozen_string_literal: true

      Check.register(
        id: "#{id}",
        desc: "TODO: describe what this assertion enforces",
        covers: ["TODO"]
      ) do |site|
        site.fail!("TODO: implement this assertion")
      end
    RUBY

    puts "script/checks/#{id}.rb created — edit it, then run `rake check:assert[#{id}]` to iterate"
  end

  desc "Regenerate _data/checks.yml from the live assertion registry"
  task :manifest do
    sh "ruby script/check.rb manifest"
  end

  desc "Print every story ID and requirement ID with no covering assertion"
  task :coverage do
    sh "ruby script/check.rb coverage"
  end

  desc "Warn (not fail) when the running Ruby differs from .ruby-version (AD-13)"
  task :env do
    pinned = File.read(File.join(File.dirname(__FILE__), ".ruby-version")).strip
    warn "rake check:env: running Ruby #{RUBY_VERSION} differs from the pinned #{pinned} (.ruby-version) — CI runs #{pinned}." unless RUBY_VERSION.start_with?(pinned)
  end
end

namespace :lint do
  desc "Run Spectral against openapi/plane-v1.yaml (a stage of rake check, and its own CI step)"
  task :openapi do
    spec_path = File.join(File.dirname(__FILE__), "openapi", "plane-v1.yaml")
    next puts "rake lint:openapi: openapi/plane-v1.yaml does not exist — nothing to lint" unless File.exist?(spec_path)

    unless spectral_on_path?
      abort(<<~MSG)
        rake lint:openapi: the spectral binary (pinned version #{SPECTRAL_VERSION}) is not on PATH.
        Install it with:
          npm install -g @stoplight/spectral-cli@#{SPECTRAL_VERSION} @stoplight/spectral-rulesets@#{SPECTRAL_RULESET_VERSION}
        Then confirm `spectral --version` reports #{SPECTRAL_VERSION}.
        The second package is not optional: without it npm resolves the rules
        to whatever is newest, and the CLI version alone does not decide the
        verdict.
      MSG
    end

    sh "spectral lint openapi/plane-v1.yaml --ruleset .spectral.yaml"
  end
end

namespace :mcp do
  desc "Regenerate _data/mcp_tools.yml from openapi/plane-v1.yaml's x-mcp-tool operations"
  task :manifest do
    spec_path = File.join(File.dirname(__FILE__), "openapi", "plane-v1.yaml")
    spec = YAML.safe_load(File.read(spec_path), permitted_classes: [Date])

    resolve_ref = lambda do |ref|
      ref.sub(%r{\A#/}, "").split("/").reduce(spec) { |node, key| node[key] }
    end

    items = spec["paths"].flat_map do |route, methods|
      methods.filter_map do |verb, op|
        next unless op.is_a?(Hash) && op["x-mcp-tool"]

        params = (op["parameters"] || []).map { |p| p["$ref"] ? resolve_ref.call(p["$ref"]) : p }

        # MCP has no request headers, so a header parameter reaches a tool only
        # under the argument name it declares in x-mcp-arg — and one that
        # declares none contributes nothing rather than surfacing to an agent
        # under a header spelling the transport would then drop.
        arg_name = lambda do |p|
          name = p["in"] == "header" ? p["x-mcp-arg"] : p["name"]
          next nil unless name

          p["required"] ? name : "#{name}?"
        end

        path_query_params, header_params = params.partition { |p| p["in"] != "header" }
        args = path_query_params.filter_map(&arg_name)

        if (body_schema = op.dig("requestBody", "content", "application/json", "schema"))
          required = body_schema["required"] || []
          (body_schema["properties"] || {}).each_key { |name| args << (required.include?(name) ? name : "#{name}?") }
        end

        # Header-derived arguments sort last: they are envelope concerns that
        # every metered tool carries, not part of the call's own shape.
        args.concat(header_params.filter_map(&arg_name))

        {
          "tool" => op["x-mcp-tool"],
          "args" => args,
          "method" => verb.upcase,
          "path" => route,
          "summary" => op["summary"],
          "operation_id" => op["operationId"]
        }
      end
    end.sort_by { |item| item["tool"] }

    envelope = {
      "meta" => {
        "owner" => "mykola",
        "verified_on" => Date.today,
        "source" => "generated by `rake mcp:manifest` from openapi/plane-v1.yaml's x-mcp-tool operations"
      },
      "items" => items
    }

    File.write(File.join(File.dirname(__FILE__), "_data", "mcp_tools.yml"), YAML.dump(envelope))
    puts "_data/mcp_tools.yml regenerated (#{items.size} tools)"
  end
end

namespace :plane do
  desc "Regenerate _data/plane_status.yml from every operation's x-status and x-mcp-tool in openapi/plane-v1.yaml"
  task :manifest do
    spec_path = File.join(File.dirname(__FILE__), "openapi", "plane-v1.yaml")
    spec = YAML.safe_load(File.read(spec_path), permitted_classes: [Date])

    http_methods = %w[get post put delete patch]

    items = spec["paths"].flat_map do |route, methods|
      methods.filter_map do |verb, op|
        next unless http_methods.include?(verb) && op.is_a?(Hash)

        {
          "operation_id" => op["operationId"],
          "method" => verb.upcase,
          "path" => route,
          "status" => op["x-status"],
          "mcp_tool" => op["x-mcp-tool"]
        }
      end
    end.sort_by { |item| item["operation_id"] }

    envelope = {
      "meta" => {
        "owner" => "mykola",
        "verified_on" => Date.today,
        "source" => "generated by `rake plane:manifest` from every operation in openapi/plane-v1.yaml"
      },
      "items" => items
    }

    File.write(File.join(File.dirname(__FILE__), "_data", "plane_status.yml"), YAML.dump(envelope))
    puts "_data/plane_status.yml regenerated (#{items.size} operations)"
  end
end

# AD-5: the build aborts rake check immediately on failure, since nothing
# downstream has an artifact to read. Once it succeeds, every other stage
# runs to completion and their failures are aggregated into one report.
#
# lint:openapi belongs here rather than beside check:build for that same
# reason — it produces no artifact anything downstream reads, so a spec
# regression should not suppress the link, prose and assertion verdicts.
# Keeping it outside this list is what made `rake check` — the one command
# this repo documents as its gate — green on a specification
# `rake lint:openapi` would reject; script/checks/check-runs-openapi-lint.rb
# pins the coupling so the two cannot drift apart again. Order within the
# list is not load-bearing: this stage was put last while a missing binary
# still ended the run where it was reported, which the loop below no longer
# lets happen.
AGGREGATED_STAGES = %w[check:links check:prose check:assert lint:openapi].freeze

desc "Run the full verification gate: build, then every check stage"
task check: "check:build" do
  # A stage reports a missing pinned tool with `abort` — check:prose without
  # vale, lint:openapi without spectral — and `abort` raises SystemExit, which
  # descends from Exception rather than StandardError. Rescuing StandardError
  # alone therefore ended the whole run at that stage: every later stage
  # silently never ran, so its verdict was unknown rather than green, and this
  # aggregate report was never reached — discarding what the stages before it
  # had already found. Rescuing SystemExit as well records the missing tool as
  # that stage's failure like any other, and leaves a standalone
  # `rake check:prose` with the clean one-line exit AD-12 wrote it for.
  # script/checks/check-aggregates-stage-aborts.rb pins this.
  failures = AGGREGATED_STAGES.each_with_object([]) do |stage, acc|
    Rake::Task[stage].invoke
  rescue StandardError, SystemExit => e
    acc << "#{stage}: #{e.message}"
  end

  abort("rake check: #{failures.size} stage#{failures.size == 1 ? '' : 's'} failed\n#{failures.join("\n")}") unless failures.empty?
end
