---
title: Retirement ledger
parent: Trust
layout: default
verified_on: 2026-08-03
owner: mykola
nav_order: 6
page_type: reference
description: Every retired URL, its replacement, and the reason it was retired — no disappearance goes unexplained.
---

# Retirement ledger

Every `redirect_from` entry in this repository, in one place. A page's URL is never simply gone —
it either still resolves, or it redirects here to a replacement, with the reason recorded below.

| Retired URL | Redirects to | Reason |
|---|---|---|
{% assign redirect_pages = site.pages | where_exp: "p", "p.redirect_from" %}{% for group in site.data.retirements.items %}{% for url in group.urls %}{% assign target = "" %}{% for p in redirect_pages %}{% if p.redirect_from contains url %}{% assign target = p.url %}{% endif %}{% endfor %}| `{{ url }}` | [`{{ target }}`]({{ target }}) | {{ group.reason }} |
{% endfor %}{% endfor %}
