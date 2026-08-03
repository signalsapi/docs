# frozen_string_literal: true

# Story 11.6's other half. pricing-figures-sourced (7.7) checks the items that
# exist; pricing-page-renders-from-data (11.6) checks that pricing.md types no
# figure by hand. Neither checks that the Liquid tag in between actually names
# a real item — and _includes/pricing-figure.html renders an unknown name as
# the literal "**[unknown pricing figure: <name>]**", on the live page, with a
# green build. So retiring a figure (signalsapi-4279 retired two) is a
# two-sided edit that nothing held together: delete the item, forget the
# include, and the page publishes a broken-reference marker to customers.
# Same shape as term-include-keys-resolve (4.3) for the glossary.
Check.register(
  id: "pricing-figure-names-resolve",
  desc: "Every include pricing-figure.html name=\"...\" invocation names an item that exists in _data/pricing.yml",
  covers: ["11.6"]
) do |site|
  site.fail!("_data/pricing.yml is missing") unless site.data["pricing"]

  names = (site.data["pricing"]["items"] || []).map { |item| item["name"] }

  # The invocations are the subject, not the pages they sit on: move every
  # figure behind a template or a data-driven table and this reads all 58 pages
  # while checking nothing, which is the state signalsapi-4292 found by hand.
  invocations = site.examining(
    "pricing-figure.html invocations",
    site.pages.flat_map do |page|
      page.body.scan(/include\s+pricing-figure\.html\s+([^%]*)%\}/).map { |match| [page.path, match.first] }
    end
  )

  offenders = invocations.filter_map do |path, args|
    name = args[/\bname=["']([^"']+)["']/, 1]
    "#{path}: #{name || args.strip.inspect}" unless names.include?(name)
  end

  site.fail!("pricing-figure.html invoked with unresolved name(s): #{offenders.join(', ')}") unless offenders.empty?
end
