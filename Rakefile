# frozen_string_literal: true

require "rake"

namespace :check do
  desc "Build the Jekyll site into _site/"
  task :build do
    sh "bundle exec jekyll build"
  end

  desc "Run script/check.rb assertions against the site"
  task :assert do
    sh "ruby script/check.rb"
  end
end

desc "Run the full verification gate: build, then every check stage"
task check: %w[check:build check:assert]
