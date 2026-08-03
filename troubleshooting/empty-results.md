---
title: Empty lead list
parent: Troubleshooting
layout: default
verified_on: 2026-08-02
owner: mykola
nav_order: 1
page_type: symptom
search_aliases:
  - empty lead list
  - no leads
  - zero results
  - project has no leads
  - lead list came back empty
description: Every known cause of a lead list with no usable leads, in order of likelihood, with the check that confirms each.
---

# Empty lead list

## What you are seeing

You created a search, a persona ran, and the resulting project shows zero leads — or leads with
no name, email, or phone attached.

## Most likely cause

No people-data provider is connected. Without one, your account is on the free tier: company
signals only, no people data — so a company can match your search and still never produce a
usable lead. Check **Settings → Provider**: if it shows no key, or an **invalid** status, this is
why. See [Bring your own people-data provider](/features/bring-your-own-people-provider/).

## Check this first

Open **Settings → Provider**. If the status is blank or **invalid**, that's the cause — connect a
key, or fix the rejected one, then re-run.

## Other causes

- **Filters combined too strictly.** Required words across different fields are ANDed together, so
  stacking them narrows results faster than expected. See [Create a search](/create-a-search/).
- **Minimum decision-maker or email thresholds are set too high**, filtering out every company
  that didn't meet them — see the 2024-04-16 entry on [What's new](/whats-new/).
- **Your account balance is too low**, which pauses a scheduled search until you top up — see
  [What's new](/whats-new/).
- **The search hasn't run yet.** Searches are topped up continuously in the background rather than
  on a per-plan schedule, so a brand-new one fills shortly after you create it, not instantly. See
  [Pricing](/pricing/#run-frequency).
- **Phone numbers specifically are missing** even though other fields are populated — phone lookup
  only works with a connected **LeadMagic** key. See [Find phone numbers](/features/find-phone-numbers/).

## Still stuck

Check [Is it working?](/faq/#is-it-working) for a platform-wide issue, or contact
[Support](/support/) with your search and persona settings.
