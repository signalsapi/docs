---
title: Wrong companies
parent: Troubleshooting
layout: default
nav_order: 3
page_type: symptom
search_aliases:
  - wrong companies
  - irrelevant companies
  - companies don't fit
  - matches outside my ICP
  - not my target companies
description: Which filter narrows which kind of mismatch, so you can tighten a search instead of abandoning it.
---

# Wrong companies

## What you are seeing

Signals are matching, but many of the companies don't fit your intended profile — wrong industry,
wrong size, wrong location, or a staffing agency posting on someone else's behalf.

## Most likely cause

Your search is only filtering by job title and keywords — company-level filters are opt-in and
none are set yet. An unfiltered search matches every company whose posting matches your keywords,
regardless of industry, size, or location. See [Company attributes](/features/advanced-search/#company-attributes).

## Check this first

Open your search's filter settings and check whether any company attribute filters — industries,
company size, headquarters location — are set at all.

## Other causes

- **Location matched on the wrong dimension.** A signal, its company, and its decision-maker each
  have an independent location — matching your target region on one doesn't mean the company is
  actually based there. See [Location-based filtering](/features/location-based-filtering/).
- **Staffing and recruiting agencies aren't excluded.** Turn on "Exclude staffing agencies"
  instead of relying on stop words. See [Advanced search](/features/advanced-search/#exclude-staffing-agencies).
- **The company is hiring on behalf of a client**, not itself — this looks identical to a real
  intended-profile match unless you specifically filter it out. See
  [Filter leads with AI](/features/filter-leads-with-ai/).
- **The role itself is out of scope** — wrong job family or a missing required skill — even though
  the company fits. See [Job families](/features/advanced-search/#job-families) and
  [Skills filter](/features/advanced-search/#skills-filter).

## Still stuck

Check [Is it working?](/is-it-working/) or contact
[Support](/support/) with your search and filter settings.
