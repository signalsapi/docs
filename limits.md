---
title: Limits
parent: Trust
layout: default
verified_on: 2026-08-02
owner: mykola
nav_order: 4
page_type: reference
description: Every documented pagination default, size cap, and rate limit in one place.
---

# Limits

Every limit stated on another page, consolidated here. Each row names its owning page — that page
is the source; this one is the index. A limit with no number yet carries an owner-marked
placeholder instead of a guess.

| Limit | Value | Enforced today | Owning page |
|---|---|---|---|
{% for item in site.data.limits.items %}{% assign owning_url = item.owning_page | remove: ".md" | prepend: "/" | append: "/" %}| {{ item.limit }} | {{ item.value }} | {% if item.enforced_today %}Yes{% else %}No{% endif %} | [`{{ item.owning_page }}`]({{ owning_url }}) |
{% endfor %}
