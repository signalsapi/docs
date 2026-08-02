---
title: Create a search
parent: Features
layout: default
verified_on: 2026-08-02
owner: mykola
nav_order: 21
stage: signal_discovery
page_type: task
description: Every field on the search-creation screen, how they combine, and where to read the full reference.
---

# Create a search

## Before you start

You don't need anything special — just the job titles, keywords, or role description you want to
match. Every field below is documented in full, with examples, on
[Advanced search](/features/advanced-search/); this page names all of them in one place and shows
how they combine.

## Steps

1. Go to **Search → Add Search**.
2. Pick a starting method — a search needs at least one of these to know what to match:
   - [Keyword search (Search for)](/features/advanced-search/#keyword-search-search-for) — one job
     title or keyword per line.
   - [Semantic search](/features/advanced-search/#semantic-search) — a natural-language
     description of the role.
3. Optionally narrow the search with any of these fields. Within a single field, the terms you
   list are combined with OR logic (match any one); across different fields, requirements are
   combined with AND logic (all listed fields must hold):
   - [Job title required words, job description required words, and stop words](/features/advanced-search/#job-title-and-description-requirements)
   - [Required skills and exclude skills](/features/advanced-search/#skills-filter)
   - [Job families](/features/advanced-search/#job-families)
   - [Search location and location patterns](/features/advanced-search/#location-filters)
   - [Maximum age of job posting](/features/advanced-search/#date-filter)
   - [Exclude staffing agencies](/features/advanced-search/#exclude-staffing-agencies)
   - [Headquarters location, industries, company size, and company required/stop words](/features/advanced-search/#company-attributes)
   - [Hard to fill](/features/advanced-search/#hard-to-fill) and [hiring surge](/features/advanced-search/#hiring-surge)
4. Save the search. It runs continuously against new signals from then on — see
   [How it works](/how-it-works/) for what happens to a signal after it matches.

## Check it worked

New signals matching your criteria start appearing as the search runs. If you also set up a
[persona](/features/find-decision-makers/), decision-makers for those signals follow next.

## If it did not work

Zero results usually means the filters combined are stricter than intended — remember that
required words across different fields are ANDed together, so adding a second field's requirement
narrows results rather than widening them. Loosen or remove a filter one at a time, starting with
the most specific one you added last. If you're getting results but they're not the companies you
expected, see [I'm getting the wrong companies](/troubleshooting/wrong-companies/). If you added an
AI filter on top and it started rejecting everything, see
[My AI filter rejected everything](/troubleshooting/ai-filter-too-strict/). If none of that
explains it, check [Is it working?](/is-it-working/) or the [FAQ](/faq/).
