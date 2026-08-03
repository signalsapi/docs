# frozen_string_literal: true

Check.register(
  id: "gemfile-html-proofer-pinned",
  desc: "Gemfile declares html-proofer with a ~> 5 constraint",
  covers: ["1.3"]
) do |site|
  gemfile = site.raw("Gemfile")
  unless gemfile =~ /gem\s+["']html-proofer["']\s*,\s*["']~>\s*5(\.\d+)*["']/
    site.fail!("Gemfile must declare `gem \"html-proofer\", \"~> 5\"`")
  end
end
