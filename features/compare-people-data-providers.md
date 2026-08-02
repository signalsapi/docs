---
title: Compare people-data providers
parent: Features
layout: default
nav_order: 9
---

# Compare people-data providers

You [connect one people-data provider](../bring-your-own-people-provider/) with your own API key.
Every supported provider returns people and emails, but they differ in **what extra data comes
back** (mobile numbers, LinkedIn headlines) and **which filters they apply at the source** versus
after the fetch. This page compares all eight so you can pick the one that fits your targeting and
your budget.

SignalsAPI charges **no credits** for people lookups — you only ever pay your own provider.

## What you get

| Provider | Email | Mobile phone | LinkedIn profile | Headline | Credentials to paste |
|---|---|---|---|---|---|
| **[Anymail Finder](https://anymailfinder.com/?via=signalsapi)** | ✅ verified | — | ✅ | — | API key |
| **Icypeas** | ✅ verified | — | ✅ | ✅ | API key |
| **People Data Labs** | ✅ verified | — | ✅ | ✅ | API key |
| **[Prospeo](https://prospeo.io/?via=signalsapi)** | ✅ verified | — | ✅ | ✅ | API key |
| **[Snov.io](https://snov.io/?fp_ref=signalsapi)** | ✅ verified | — | partial | — | Client ID + Client Secret |
| **Hunter** | ✅ verified | — | ✅ | — | API key |
| **LeadMagic** | ✅ verified | ✅ | ✅ | — | API key |
| **Tomba** | ✅ verified | — | ✅ | — | Key + Secret |

- **Mobile phone** is only returned by **LeadMagic** today, and only when
  [Find phone numbers](../find-phone-numbers/) is enabled.
- **Headline** is the person's LinkedIn one-liner (e.g. *"VP Engineering at Acme"*). Providers that
  return it — **Icypeas, People Data Labs, [Prospeo](https://prospeo.io/?via=signalsapi)** — give you more context for AI personalization.
- Every provider returns a LinkedIn profile URL for matched people ([Snov.io](https://snov.io/?fp_ref=signalsapi) returns it for some).

## Where each filter runs

This is the part that affects your **provider bill**. A filter runs in one of two places:

- **At source** — sent to the provider's search API. People come back already filtered, so you
  only pay for matches.
- **After fetch** — applied by SignalsAPI once the people are returned. Anything it removes is a
  person the provider already charged you to look up. In the persona form these are flagged
  **"extra spend"**.

A dash (**—**) means the provider doesn't support that filter at all. SignalsAPI simply won't
offer it for that provider — it never silently drops your leads on a filter the provider can't
honor.

| Provider | Title | Country | City | Skills | Department | Seniority |
|---|---|---|---|---|---|---|
| **[Anymail Finder](https://anymailfinder.com/?via=signalsapi)** | after fetch | — | — | — | — | — |
| **Icypeas** | at source | after fetch | after fetch | at source | — | — |
| **People Data Labs** | at source | **at source** | **at source** | at source | — | — |
| **[Prospeo](https://prospeo.io/?via=signalsapi)** | at source | after fetch | after fetch | — | — | — |
| **[Snov.io](https://snov.io/?fp_ref=signalsapi)** | at source | — | — | — | — | — |
| **Hunter** | after fetch | — | — | — | **at source** | **at source** |
| **LeadMagic** | after fetch | — | after fetch | — | — | — |
| **Tomba** | after fetch | — | — | — | **at source** | — |

**Rule of thumb:** the more filters a provider applies *at source*, the fewer credits you waste on
people who get filtered out. **People Data Labs** filters the most at source (title, country, city,
skills). **Hunter** and **Tomba** can't filter by job title at source — they pull everyone in the
chosen **department** and then match titles afterwards, so a broad title list costs more.

## Provider details

### Anymail Finder
Domain-based decision-maker lookup: it maps your job-title list to a decision-maker category and
returns the matching person per company. **Job title** is matched after fetch; no country, city,
skills, or headline. Email comes inline and verified. Resolves people from the company **domain
alone** — no LinkedIn profile needed — so it also works on companies with no LinkedIn page. Get an
API key at [anymailfinder.com](https://anymailfinder.com/?via=signalsapi). **One API key.**

### Icypeas
People search with title and skills filtered at source; country and city matched after fetch.
Returns LinkedIn profile **and headline**. Email verification is asynchronous (a short poll), then
only verified emails are kept. **One API key.**

### People Data Labs
The most filterable provider: title, country, city, and skills all run **at source**, so broad
searches stay cheap. Returns LinkedIn profile and headline. **One API key.**

### Prospeo
Title filtered at source; country and city after fetch. Returns LinkedIn profile and headline.
Get an API key at [prospeo.io](https://prospeo.io/?via=signalsapi). **One API key.**

### Snov.io
Title filtered at source. No country/city/skills filtering and no headline. Uses **two secrets** —
a **Client ID** and **Client Secret** from your Snov.io API settings. Sign up at
[snov.io](https://snov.io/?fp_ref=signalsapi).

### Hunter
Builds the people list from a company-domain search, so **department** and **seniority** are
filtered at source from fixed lists, while **job title** is matched after fetch. Email comes back
inline with each person. No country/city. **One API key.**

- **Department** (pick any): executive, it, finance, management, sales, legal, support, hr,
  marketing, communication, education, design, health, operations
- **Seniority** (pick any): junior, senior, executive

### LeadMagic
The only provider that returns **mobile phone numbers** (see [Find phone numbers](../find-phone-numbers/)).
Email comes inline; title and city are matched after fetch. **One API key.**

### Tomba
Domain-search based, with **department** filtered at source from a fixed list and job title matched
after fetch. Email comes inline. Uses **two secrets** — a **Key** and a **Secret**.

- **Department** (pick any): executive, it, finance, management, communication, marketing, sales,
  legal, hr, support, engineering

## How to choose

- **You want mobile numbers** → **LeadMagic**.
- **You filter by country or city** → **People Data Labs** (the only one that does both at source).
  Icypeas, [Prospeo](https://prospeo.io/?via=signalsapi) and LeadMagic can still filter location, but after fetch (extra spend).
- **You target by department / seniority** → **Hunter** (department + seniority) or **Tomba**
  (department) — filtered at source, so precise and credit-efficient.
- **You want LinkedIn headlines for AI-written outreach** → **Icypeas**, **People Data Labs**, or
  **[Prospeo](https://prospeo.io/?via=signalsapi)**.
- **You have domain-only companies (no LinkedIn page)** → **[Anymail Finder](https://anymailfinder.com/?via=signalsapi)** — it resolves the
  decision maker from the company domain alone.
- **You already have an account somewhere** → just connect it; all eight cover the core
  people + verified-email job.

Not sure which fits? Start a trial with one provider, run a search, and check the
**fetched-vs-disqualified** breakdown on your leads — it shows exactly how many people were fetched
and why any were dropped, so you can see result quality and credit use before committing.

See also: [Bring your own people-data provider](../bring-your-own-people-provider/) ·
[Find decision makers](../find-decision-makers/) · [Find phone numbers](../find-phone-numbers/)
