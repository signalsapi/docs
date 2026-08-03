---
title: Remove duplicate signals
parent: Features
layout: default
verified_on: 2026-08-03
owner: mykola
redirect_from: "/features/remove-duplicate-signals.html"
nav_order: 2
page_type: feature
description: Choose how SignalsAPI handles the same job posted multiple times across different regions.
---

# Remove duplicate signals

Some companies post the same job multiple times in different regions — the same employer and job
title recurring across locations, e.g.:

| Company | Job title | Location |
|---|---|---|
| DataAnnotation | Frontend Developer | United States |
| DataAnnotation | Software Developer | Fremont, CA |
| DataAnnotation | Frontend Developer | Mountain View, CA |
| DataAnnotation | Web Developer | Salt Lake City Metropolitan Area |
| DataAnnotation | Software Developer | Long Beach, CA |

When setting up a [project](https://app.signalsapi.com/leadlists/), choose how the duplicates should
be handled on the **Duplicates** screen:

{% include controls-table.html screen="Duplicates" %}
