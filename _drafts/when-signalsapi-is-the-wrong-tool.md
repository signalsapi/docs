---
title: When SignalsAPI is the wrong tool
layout: default
permalink: /when-signalsapi-is-the-wrong-tool/
page_type: reference
owner: mykola
sign_off: pending
verified_on: 2026-08-02
description: The documented cases where SignalsAPI is not the right fit, named honestly.
---

# When SignalsAPI is the wrong tool

**Draft — pending owner sign-off. Not published.**

Every point below is already stated, as an aside, on another page in this repository. This page
just collects them in one place instead of making a reader find them one at a time.

## You need candidate sourcing, not client sourcing

SignalsAPI finds companies that are hiring and the decision-maker to contact there first — it
surfaces sales prospects, not job candidates. If you're staffing a role rather than selling into a
hiring company, this is not that tool.

## You want people data without connecting your own provider account

With no people-data provider key saved, your account is on the free tier: company signals only, no
people data. See [Bring your own people-data provider](/features/bring-your-own-people-provider/).

## You need mobile phone numbers and don't want to use LeadMagic

Mobile phone lookup is bring-your-own-provider, and only LeadMagic returns a phone number today —
every other connected provider leaves it empty. See [Find phone numbers](/features/find-phone-numbers/).

## You need a native Salesforce integration today

The FAQ names Salesforce as an example of the "CRMs and sales tools" SignalsAPI feeds into, but no
Salesforce integration exists among the ones actually documented on
[Integrations](/features/integrations/).

## You're pushing to Recruit CRM expecting candidates

Leads pushed to Recruit CRM land as contacts — sales-side prospects linked to the hiring company —
not as candidates. If your Recruit CRM workflow expects candidate records, this integration will
not do that.

## You need the export endpoint to enforce a rate limit

The full-project leads export endpoint does not enforce rate limiting today. See
[Limits](/limits/).

## You want to build against the agent data plane with a live key today

The agent data plane is not yet open for self-serve signup — there is no public base URL or issued
key to build against outside a fixture-based integration. See
[Agent data plane](/features/agent-data-plane/).
