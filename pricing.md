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

## The self-serve subscription

{% include pricing-figure.html name="self_serve_ladder_summary" %}

{% include pricing-ladder.html %}

A **qualifying signal** is {% include pricing-figure.html name="qualifying_signal_definition" %}

{% include pricing-figure.html name="self_serve_evaluation_tier" %}

## Free tier

{% include pricing-figure.html name="free_tier_description" %}

## The managed service

Done-with-you and done-for-you outbound are a separate offer from the subscription above, priced at
{% include pricing-figure.html name="managed_service_monthly" %} per month after a two-week test
drive. Qualified telephone numbers are their own packages:
{% include pricing-figure.html name="managed_phone_packages" %}. See the
[FAQ](/faq/#what-are-my-options-for-running-signalsapi-to-grow-my-business) for what each one covers.

## Credits

- **What a new account gets:** {% include pricing-figure.html name="trial_allowance" %}
- **Unspent credit expiry:** {% include pricing-figure.html name="credit_expiry" %}

## Run frequency

{% include pricing-figure.html name="run_frequency" %}

## Agent data plane

The plane's four meter units (`call`, `change`, `watch`, `forced_fresh`) are priced separately from
the plans above — see [Tiers and metering](/features/agent-data-plane/#tiers-and-metering).

{% include recent-changes.html %}
