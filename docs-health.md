---
title: Docs health
parent: Trust
layout: default
nav_order: 2
page_type: reference
verified_on: 2026-08-03
owner: mykola
description: Live counts of missing descriptions, empty alt text, broken links, stale pages, and orphan pages.
---

# Docs health

These five tables are generated at build time from the same corpus every assertion in
`script/check.rb` reads — nothing here is hand-maintained, so the numbers move when the content
does. See [Docs baseline](/docs-baseline/) for the one-time snapshot this workstream started from.

## Pages missing a description

{% assign rows = site.data.docs_health.missing_description %}
{% if rows.size == 0 %}
None. Every page declares a `description`.
{% else %}
| Page | Title |
|---|---|
{% for r in rows %}| `{{ r.path }}` | {{ r.title }} |
{% endfor %}
{% endif %}

## Images with empty alt text

{% assign rows = site.data.docs_health.empty_alt_images %}
{% if rows.size == 0 %}
None. Every image declares non-empty alt text.
{% else %}
| Page | Image |
|---|---|
{% for r in rows %}| `{{ r.path }}` | `{{ r.image }}` |
{% endfor %}
{% endif %}

## Broken internal links

{% assign rows = site.data.docs_health.broken_internal_links %}
{% if rows.size == 0 %}
None. Every internal link resolves to a live page.
{% else %}
| Page | Link |
|---|---|
{% for r in rows %}| `{{ r.path }}` | `{{ r.link }}` |
{% endfor %}
{% endif %}

## Pages past their verification horizon

Pages whose `verified_on` is more than 90 days old, marked red.

{% assign rows = site.data.docs_health.stale_pages %}
{% if rows.size == 0 %}
None. Every page was verified within the last 90 days.
{% else %}
<table>
<thead><tr><th>Page</th><th>Verified on</th><th>Days ago</th></tr></thead>
<tbody>
{% for r in rows %}<tr class="text-stale"><td><code>{{ r.path }}</code></td><td>{{ r.verified_on }}</td><td>{{ r.days }}</td></tr>
{% endfor %}
</tbody>
</table>
{% endif %}

## Orphan pages with zero inbound links

Pages no other page links to from its own body content.

{% assign rows = site.data.docs_health.orphan_pages %}
{% if rows.size == 0 %}
None. Every page has at least one inbound in-body link.
{% else %}
| Page | Title |
|---|---|
{% for r in rows %}| `{{ r.path }}` | {{ r.title }} |
{% endfor %}
{% endif %}

## What these tables do not measure

Reader traffic. This site loads no analytics, telemetry, or beacon — a collector needs a backend, a
retention policy, and a privacy disclosure this site does not have — and the
`no-analytics-or-telemetry` assertion keeps it that way, so no number here counts visits.

Reach on this page therefore means structural reach: whether another page links to it (the orphan
table above, gated by `no-orphan-pages`) and how recently someone verified it (the staleness table,
gated by `page-staleness`). Those two, with a page's entry in the [changelog](/whats-new/), are the
whole input to a keep-or-retire decision. The [retirement ledger](/retirement-ledger/) and the
page-count budget record what was decided; neither measures whether a page is read.
