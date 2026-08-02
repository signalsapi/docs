source 'https://rubygems.org'

gem "rake", "~> 13.0"
gem "jekyll", "~> 4.3.4" # installed by `gem jekyll`
# gem "webrick"        # required when using Ruby >= 3 and Jekyll <= 4.2.2

gem "html-proofer", "~> 5"
# html-proofer 5.2.2's process_files silently returns zero results (false-green
# "0 internal links, finished successfully") under async >= 2.24 due to a
# Fiber-scheduling regression: the child task never resumes past its first
# blocking file read. Pin to the last version verified to run checks at all.
gem "async", "~> 2.23"

gem "just-the-docs", "0.10.0" # pinned to the current release
# gem "just-the-docs"        # always download the latest release
