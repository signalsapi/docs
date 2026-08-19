---
title: Bring your own people-data provider
parent: Features
layout: default
verified_on: 2026-08-19
owner: mykola
redirect_from: "/features/bring-your-own-people-provider.html"
nav_order: 7
page_type: feature
description: Connect your own people-data provider API key so decision-maker search returns people and emails.
---

# Bring your own people-data provider

SignalsAPI finds companies that are hiring. To turn those companies into people you can
contact — the right person, their email, sometimes their mobile — connect a **people-data
provider** using **your own API key**.

* **No key** → your account is on the **free tier**: company signals only, no people data.
* **With a key** → decision-maker search returns people, and verified emails from every provider
  that has an email product — see the table below for the one that doesn't.
* **People lookups cost no SignalsAPI credits** — you only pay your provider for what you use.
* **Some signup links below pay us a referral fee** — see [How we make money](/how-we-make-money/).

You manage everything on one screen: **Settings → Provider**.

{% include screenshot.html path="features/byo-people-provider-1.png" width="720" %}

## Choose your provider

Open the **Provider** dropdown and pick the provider you already have an account with. Each
option says what it returns — *people search*, for most *+ email*, and for some *+ mobile*. You connect
**one provider at a time**. To see how the providers differ on data and filtering, see
[Compare people-data providers](../compare-people-data-providers/).

| Provider | What you get | Paste | Get your key |
|---|---|---|---|
{% for p in site.data.providers.items %}| **{{ p.name }}** | people{% if p.email == "verified" %} + email{% else %} only — **no email**{% endif %}{% if p.mobile_support %} **+ mobile**{% endif %} | {% case p.credential_shape %}{% when "api_key" %}API key{% when "client_id_and_secret" %}Client ID **+** Client Secret{% when "key_and_secret" %}Key **+** Secret{% endcase %} | {% include provider-link.html name=p.name cost=false %}{% if p.mobile_support %} — see [Find phone numbers](../find-phone-numbers/){% endif %} |
{% endfor %}

## Enter your key

The form shows exactly the fields your provider needs. Most use a single **API key**; a few use
two secrets — for example **{% include provider-link.html name="Snov.io" cost=false %}** asks for a **Client ID** and a **Client Secret** (found at
[app.snov.io/account/api](https://app.snov.io/account/api)), which appear as soon as you select it.

{% include screenshot.html path="features/byo-people-provider-2.png" width="720" %}

Paste your value(s) and click **Save & validate**. SignalsAPI checks the key with the provider
straight away — it doesn't just store whatever you typed.

## Confirming it works

If the key is accepted you get a green confirmation and an **active** status. Only a masked
fingerprint of your key (the last 4 characters) is ever shown.

{% include screenshot.html path="features/byo-people-provider-3.png" width="720" %}

If the provider rejects it, the status is **invalid** and no people data is fetched until you
fix it.

{% include screenshot.html path="features/byo-people-provider-4.png" width="720" %}

If you see **invalid**, check that you:

1. Copied the full key with no extra spaces.
2. Selected the right provider.
3. Filled both fields for two-secret providers ({% include provider-link.html name="Snov.io" cost=false %}, Tomba).
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
3. **Email lookup** runs only for the survivors — and only verified emails are kept. Providers with
   no email product are skipped here, and a project with **"Email is required"** on won't spend
   anything against one.
4. **Phone lookup** runs last, only for surviving leads, when [Find phone numbers](../find-phone-numbers/)
   is enabled and your provider supports it (currently {% assign mobile_providers = site.data.providers.items | where: "mobile_support", true %}{% for p in mobile_providers %}{{ p.name }}{% unless forloop.last %}, {% endunless %}{% endfor %} only).

## Your key is safe

Credentials are encrypted at rest, never displayed back (only the masked fingerprint), and used
solely to call your provider on your behalf — never logged or shared.

{% include recent-changes.html %}
