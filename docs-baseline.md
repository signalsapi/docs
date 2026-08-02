---
title: Docs baseline
parent: Trust
layout: default
nav_order: 1
page_type: reference
verified_on: 2026-07-31
owner: mykola
description: The measured as-is state of this site on 2026-07-31, before this documentation overhaul began.
---

# Docs baseline

This is the site's measured condition on **2026-07-31**, the day of the audit this overhaul
responds to, captured before any of the overhaul's own changes landed. Every later claim of
improvement should be checkable against these numbers, not against memory.

Verified by {{ site.data.baseline.meta.owner }} on {{ site.data.baseline.meta.verified_on }}.
Source: {{ site.data.baseline.meta.source }}.

| Dimension | 2026-07-31 value |
|---|---|
{% for pair in site.data.baseline.items %}| `{{ pair[0] }}` | {{ pair[1] }} |
{% endfor %}

**Next scheduled re-measurement:** when every epic in this overhaul ships, tracked against the
live findings `bundle exec rake check` reports today — see [Docs health](/docs-health/) for the
current numbers.
