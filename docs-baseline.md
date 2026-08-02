---
title: Docs baseline
layout: default
nav_order: 9
description: The measured as-is state of this site on 2026-07-31, before this documentation overhaul began.
---

# Docs baseline

This is the site's measured condition on **2026-07-31**, the day of the audit this overhaul
responds to, captured before any of the overhaul's own changes landed. Every later claim of
improvement should be checkable against these numbers, not against memory.

| Dimension | 2026-07-31 value |
|---|---|
{% for pair in site.data.baseline %}| `{{ pair[0] }}` | {{ pair[1] }} |
{% endfor %}

**Next scheduled re-measurement:** when every epic in this overhaul ships, tracked against the
live findings `bundle exec rake check` reports today.
