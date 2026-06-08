---
title: Bring your own people-data provider
parent: Features
layout: home
nav_order: 3.5
---

# Bring your own people-data provider

SignalsAPI finds companies that are hiring. To turn those companies into people you can
contact — the right person, their email, sometimes their mobile — connect a **people-data
provider** using **your own API key**.

* **No key** → your account is on the **free tier**: company signals only, no people data.
* **With a key** → decision-maker search returns people and verified emails using your provider account.
* **People lookups cost no SignalsAPI credits** — you only pay your provider for what you use.

You manage everything on one screen: **Settings → Provider**.

<figure><img src="/features/byo-people-provider-1.png" alt="People-data provider settings with no key saved" width="720"><figcaption></figcaption></figure>

## Choose your provider

Open the **Provider** dropdown and pick the provider you already have an account with. Each
option says what it returns — *people search + email*, and for some *+ mobile*. You connect
**one provider at a time**. To see how the providers differ on data and filtering, see
[Compare people-data providers](compare-people-data-providers).

| Provider | What you get | Paste | Get your key |
|---|---|---|---|
| Hunter | people + email | API key | [hunter.io](https://hunter.io) |
| Icypeas | people + email | API key | [icypeas.com](https://icypeas.com) |
| LeadMagic | people + email **+ mobile** | API key | [leadmagic.io](https://leadmagic.io) — see [Find phone numbers](find-phone-numbers) |
| People Data Labs | people + email | API key | [peopledatalabs.com](https://peopledatalabs.com) |
| Prospeo | people + email | API key | [prospeo.io](https://prospeo.io) |
| Snov.io | people + email | Client ID **+** Client Secret | [app.snov.io/account/api](https://app.snov.io/account/api) |
| Tomba | people + email | Key **+** Secret | [tomba.io](https://tomba.io) |

## Enter your key

The form shows exactly the fields your provider needs. Most use a single **API key**; a few use
two secrets — for example **Snov.io** asks for a **Client ID** and a **Client Secret**, which
appear as soon as you select it.

<figure><img src="/features/byo-people-provider-2.png" alt="Snov.io selected, showing Client ID and Client Secret fields" width="720"><figcaption></figcaption></figure>

Paste your value(s) and click **Save & validate**. SignalsAPI checks the key with the provider
straight away — it doesn't just store whatever you typed.

## Confirming it works

If the key is accepted you get a green confirmation and an **active** status. Only a masked
fingerprint of your key (the last 4 characters) is ever shown.

<figure><img src="/features/byo-people-provider-3.png" alt="Key saved with active status" width="720"><figcaption></figcaption></figure>

If the provider rejects it, the status is **invalid** and no people data is fetched until you
fix it.

<figure><img src="/features/byo-people-provider-4.png" alt="Key rejected, invalid status" width="720"><figcaption></figcaption></figure>

If you see **invalid**, check that you:

1. Copied the full key with no extra spaces.
2. Selected the right provider.
3. Filled both fields for two-secret providers (Snov.io, Tomba).
4. Haven't revoked or rotated the key — regenerate it if unsure.

A key that was active can later turn **invalid** if the provider revokes it. If people data
suddenly stops appearing, check this page.

## Removing or switching

Click **Remove key** to delete your credentials — your account returns to the free tier. To
switch providers, just select another provider and save a new key; it replaces the previous one.

## How lookups are staged

When SignalsAPI builds your leads it uses your provider in a cost-staged order, so you don't pay
for people you'll never contact:

1. **People search** at the hiring company.
2. **AI qualification** ranks and cuts the list.
3. **Email lookup** runs only for the survivors — and only verified emails are kept.
4. **Phone lookup** runs last, only for surviving leads, when [Find phone numbers](find-phone-numbers)
   is enabled and your provider supports it (currently LeadMagic only).

## Your key is safe

Credentials are encrypted at rest, never displayed back (only the masked fingerprint), and used
solely to call your provider on your behalf — never logged or shared.
