# frozen_string_literal: true

require "rake"

namespace :check do
  desc "Build the Jekyll site into _site/"
  task :build do
    sh "bundle exec jekyll build"
  end

  desc "Run html-proofer against the built site (external checking disabled)"
  task :links do
    sh "bundle exec htmlproofer _site --disable-external"
  end

  desc "Run script/check.rb assertions against the site"
  task :assert do
    sh "ruby script/check.rb"
  end
end

# AD-5: the build aborts rake check immediately on failure, since nothing
# downstream has an artifact to read. Once it succeeds, every other stage
# runs to completion and their failures are aggregated into one report.
AGGREGATED_STAGES = %w[check:links check:assert].freeze

desc "Run the full verification gate: build, then every check stage"
task check: "check:build" do
  failures = AGGREGATED_STAGES.each_with_object([]) do |stage, acc|
    Rake::Task[stage].invoke
  rescue StandardError => e
    acc << "#{stage}: #{e.message}"
  end

  abort("rake check: #{failures.size} stage#{failures.size == 1 ? '' : 's'} failed\n#{failures.join("\n")}") unless failures.empty?
end
