---
title: Blank phone column
parent: Troubleshooting
layout: default
nav_order: 2
page_type: symptom
search_aliases:
  - blank phone column
  - no phone numbers
  - phone column empty
  - missing phone numbers
  - phone number not showing
description: Why the Phone column stays empty even after decision-makers are found, and how to fix it.
---

# Blank phone column

## What you are seeing

Phone lookup is enabled and decision-makers are being found with names and emails, but the
**Phone** column stays empty — or shows a dash — for every lead.

## Most likely cause

Mobile phone numbers are only ever returned by **LeadMagic** — no other connected people-data
provider supports phone lookup, regardless of your persona or plan settings. Check
**Settings → Provider**: if you're connected to any provider other than LeadMagic, that's why the
Phone column is empty. See [Compare people-data providers](/features/compare-people-data-providers/).

## Check this first

Open **Settings → Provider** and confirm **LeadMagic** is the connected provider. If it's any
other provider, phone lookup will never populate no matter what else you change — see
[Bring your own people-data provider](/features/bring-your-own-people-provider/).

## Other causes

- **"Find phone numbers" isn't enabled on the persona.** Open the persona's settings and tick the
  checkbox — see [Find phone numbers](/features/find-phone-numbers/).
- **The provider searched but found nothing for that person.** A dash (—) means a real, completed
  lookup with no result — this is expected best-effort coverage, not a bug. See
  [Find phone numbers](/features/find-phone-numbers/).
- **Personation hasn't finished running yet.** The Phone column populates as personation
  completes, the same as email — give it time before assuming it failed. See
  [How it works](/how-it-works/).

## Still stuck

Check [Is it working?](/is-it-working/) for a platform-wide issue, or contact
[Support](/support/) with which provider you have connected.
