# frozen_string_literal: true

# Story 11.6: pricing.md exists precisely so a figure is never hand-typed
# into it — every value comes from _data/pricing.yml via a Liquid tag. This
# strips Liquid tags from the SOURCE (not the built output, where every
# {{ }} has already become a real figure) and fails if a bare currency
# symbol survives outside one, the same "AD-7/NFR3" rule
# currency-outside-data.rb (2.9) already enforces site-wide, made explicit
# for the one page whose entire job is rendering these figures.
Check.register(
  id: "pricing-page-renders-from-data",
  desc: "pricing.md contains no currency symbol outside a Liquid-rendered block",
  covers: ["11.6"]
) do |site|
  page = site.pages.find { |p| p.path == "pricing.md" }
  site.fail!("pricing.md is missing") unless page

  without_liquid = page.body.gsub(/\{%.*?%\}/m, "").gsub(/\{\{.*?\}\}/m, "")

  site.fail!("pricing.md has a currency symbol outside a Liquid-rendered block") if without_liquid =~ /[£$€]\s?\d/
end
