# frozen_string_literal: true

require "rake"

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

# AD-5: the build aborts rake check immediately on failure, since nothing
# downstream has an artifact to read. Once it succeeds, every other stage
# runs to completion and their failures are aggregated into one report.
AGGREGATED_STAGES = %w[check:links check:prose check:assert].freeze

desc "Run the full verification gate: build, then every check stage"
task check: "check:build" do
  failures = AGGREGATED_STAGES.each_with_object([]) do |stage, acc|
    Rake::Task[stage].invoke
  rescue StandardError => e
    acc << "#{stage}: #{e.message}"
  end

  abort("rake check: #{failures.size} stage#{failures.size == 1 ? '' : 's'} failed\n#{failures.join("\n")}") unless failures.empty?
end
