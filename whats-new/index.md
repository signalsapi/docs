---
title: Release Notes / Changelog
layout: default
verified_on: 2026-08-03
owner: mykola
nav_order: 5
page_type: changelog
description: The dated changelog of every SignalsAPI feature, fix, and behavior change since launch.
---

# What's new

Every entry below renders from `_data/changelog.yml` — the same data that drives the "Recent changes"
block on each feature page it names.

{% assign entries = site.data.changelog.items | sort: "date" | reverse %}
{% assign current_date = "" %}
{% for e in entries %}
{% assign date_str = e.date | date: "%d.%m.%Y" %}
{% if date_str != current_date %}
{% assign current_date = date_str %}

## {{ current_date }}
{% endif %}
{% assign target = site.pages | where: "path", e.feature | first %}
- {{ e.summary }}{% if target %} — see [{{ target.title }}]({{ target.url }}){% endif %}
{% endfor %}
