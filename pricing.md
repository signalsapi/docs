---
title: Pricing
parent: Trust
layout: default
verified_on: 2026-08-03
owner: mykola
nav_order: 5
page_type: reference
description: SignalsAPI's plans and figures, every one of them rendered from the same data file cited everywhere else.
---

# Pricing

Every figure on this page renders from `_data/pricing.yml` — the one place a price, an allowance, or
an expiry window is allowed to live. Where we don't yet have a confirmed figure, the page says so
plainly instead of guessing.

{% assign items = site.data.pricing.items %}
{% assign free_tier = items | where: "name", "free_tier_description" | first %}
{% assign plan_price = items | where: "name", "subscription_plan_price" | first %}
{% assign credit_allowance = items | where: "name", "free_tier_credit_allowance" | first %}
{% assign trial_allowance = items | where: "name", "trial_allowance" | first %}
{% assign credit_expiry = items | where: "name", "credit_expiry" | first %}
{% assign run_frequency = items | where: "name", "run_frequency_by_plan" | first %}

## Free tier

{{ free_tier.value }}

## Paid plan

{{ plan_price.value }}

## Credits

- **Free-tier allowance:** {{ credit_allowance.value }}
- **Trial allowance:** {{ trial_allowance.value }}
- **Unspent credit expiry:** {{ credit_expiry.value }}

## Run frequency

{{ run_frequency.value }}

## Agent data plane

The plane's four meter units (`call`, `change`, `watch`, `forced_fresh`) are priced separately from
the plans above — see [Tiers and metering](/features/agent-data-plane/#tiers-and-metering).

{% include recent-changes.html %}
