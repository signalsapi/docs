---
title: How we make money
parent: Trust
layout: default
nav_order: 3
page_type: reference
verified_on: 2026-08-02
owner: mykola
description: SignalsAPI charges no credits for people lookups; some provider signup links pay us a referral fee.
---

# How we make money

SignalsAPI charges **no credits** for people lookups — you connect your own people-data provider
with your own API key, and you pay that provider directly for what you use. See
[Compare people-data providers](/features/compare-people-data-providers/) and
[Bring your own people-data provider](/features/bring-your-own-people-provider/).

## Referral fees

A signup link for some providers pays SignalsAPI a referral fee if you create an account through
it. Every such link on this site carries `rel="sponsored nofollow"` and is disclosed at the point
it appears — this page is the one place that names all of them together.

{% assign affiliate_providers = site.data.providers.items | where: "affiliate", true %}
| Provider |
|---|
{% for p in affiliate_providers %}| **{% include provider-link.html name=p.name cost=false %}** |
{% endfor %}

Choosing one of these does not cost you anything extra, and it does not affect what that provider
charges you — the referral fee comes out of the provider's own margin, not yours.

## Why bring-your-own is still cheaper than a bundled reseller

If SignalsAPI resold people-data access instead of asking you to bring your own key, every lookup
would need to clear SignalsAPI's own margin on top of the provider's own price. Because you connect
your own account and pay the provider directly, there's no markup for SignalsAPI to add — a
referral fee on signup doesn't change what any individual lookup costs you.
