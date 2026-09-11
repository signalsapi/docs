---
title: Compare people-data providers
parent: Features
layout: default
verified_on: 2026-09-11
owner: mykola
redirect_from: "/features/compare-people-data-providers.html"
nav_order: 9
page_type: feature
description: How the thirteen supported people-data providers differ on data returned and where filters run.
---

# Compare people-data providers

You [connect one people-data provider](../bring-your-own-people-provider/) with your own API key.
Providers differ in **what data comes back** (emails at all, mobile numbers, LinkedIn headlines) and
**which filters they apply at the source** versus after the fetch. This page compares all thirteen so
you can pick the one that fits your targeting and your budget.

SignalsAPI charges **no credits** for people lookups — you only ever pay your own provider. Some
signup links below pay us a referral fee — see [How we make money](/how-we-make-money/) for which
ones and why it doesn't change what you pay.

## What you get

| Provider | Email | Mobile phone | LinkedIn profile | Headline | Credentials to paste |
|---|---|---|---|---|---|
{% for p in site.data.providers.items %}| **{% include provider-link.html name=p.name cost=false %}** | {% if p.email == "verified" %}✅ verified{% else %}—{% endif %} | {% if p.mobile_support %}✅{% else %}—{% endif %} | {% if p.linkedin_profile == "full" %}✅{% else %}partial{% endif %} | {% if p.headline %}✅{% else %}—{% endif %} | {% case p.credential_shape %}{% when "api_key" %}API key{% when "client_id_and_secret" %}Client ID + Client Secret{% when "key_and_secret" %}Key + Secret{% endcase %} |
{% endfor %}

- **Email** — a dash means the provider has no email product at all, so no address ever comes back
  for it. Projects with **"Email is required"** on won't spend credits on such a provider.
- **Mobile phone** is only returned by the provider(s) marked ✅ above, and only when
  [Find phone numbers](../find-phone-numbers/) is enabled.
- **Headline** is the person's LinkedIn one-liner (e.g. *"VP Engineering at Acme"*). Providers that
  return it give you more context for AI personalization.
- Every provider returns a LinkedIn profile URL for matched people (providers marked **partial**
  above return it for some, not all).

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

{% assign filter_keys = "title,country,city,skills,department,seniority" | split: "," %}

| Provider | Title | Country | City | Skills | Department | Seniority |
|---|---|---|---|---|---|---|
{% for p in site.data.providers.items %}| **{% include provider-link.html name=p.name cost=false %}** |{% for key in filter_keys %} {% assign v = p.filters[key] %}{% if v == "at_source" %}at source{% elsif v == "after_fetch" %}after fetch{% else %}—{% endif %} |{% endfor %}
{% endfor %}

**Rule of thumb:** the more filters a provider applies *at source*, the fewer credits you waste on
people who get filtered out. **People Data Labs**, **Limadata** and **Wiza** filter the most at
source (title, country, city, skills). **BetterContact** runs five filters at source (title,
country, skills, department, seniority) but has no city filter at all. **Hunter** and **Tomba**
can't filter by job title at source — they pull everyone in the chosen **department** and then
match titles afterwards, so a broad title list costs more.

## Provider details

### Anymail Finder
Domain-based decision-maker lookup: it maps your job-title list to a decision-maker category and
returns the matching person per company. **Job title** is matched after fetch; no country, city,
skills, or headline. Email comes inline and verified. Resolves people from the company **domain
alone** — no LinkedIn profile needed — so it also works on companies with no LinkedIn page. Get an
API key at {% include provider-link.html name="Anymail Finder" text="anymailfinder.com" %}. **One API key.**

### Icypeas
People search with title and skills filtered at source; country and city matched after fetch.
Returns LinkedIn profile **and headline**. Email verification is asynchronous (a short poll), then
only verified emails are kept. **One API key.**

### People Data Labs
Title, country, city, and skills all run **at source**, so broad searches stay cheap. Returns
LinkedIn profile and headline. **One API key.**

### Prospeo
Title filtered at source; country and city after fetch. Returns LinkedIn profile and headline.
Get an API key at {% include provider-link.html name="Prospeo" text="prospeo.io" %}. **One API key.**

### Snov.io
Title filtered at source. No country/city/skills filtering and no headline. Uses **two secrets** —
a **Client ID** and **Client Secret** from your Snov.io API settings. Sign up at
{% include provider-link.html name="Snov.io" text="snov.io" %}.

### Hunter
Builds the people list from a company-domain search, so **department** and **seniority** are
filtered at source from fixed lists, while **job title** is matched after fetch. Email comes back
inline with each person. No country/city. **One API key.**

- **Department** (pick any): executive, it, finance, management, sales, legal, support, hr,
  marketing, communication, education, design, health, operations
- **Seniority** (pick any): junior, senior, executive

### LeadMagic
Returns **mobile phone numbers** (see [Find phone numbers](../find-phone-numbers/)).
Email comes inline; title and city are matched after fetch. **One API key.**

### Tomba
Domain-search based, with **department** filtered at source from a fixed list and job title matched
after fetch. Email comes inline. Also returns **mobile phone numbers** (see
[Find phone numbers](../find-phone-numbers/)), can resolve an email from the decision-maker's own
LinkedIn profile instead of a guessed company domain, and runs a separate deliverability check so
only verified addresses are kept. Uses **two secrets** — a **Key** and a **Secret**.

- **Department** (pick any): executive, it, finance, management, communication, marketing, sales,
  legal, hr, support, engineering
- Phone numbers cost **5 credits** each against a separate phone allowance, against 1 credit per
  email. Deliverability checks draw a **bundled verification allowance** — 5,000 on the entry plan,
  alongside 5,000 finder credits — rather than your finder credits. Failed lookups are not charged,
  and repeating the same domain search inside one calendar month is not charged twice.

### Limadata
Structured people-database search: title, country, city, and skills all run **at source** as a hard
match, so broad searches stay cheap. Returns LinkedIn profile **and headline**, plus **mobile phone
numbers** (see [Find phone numbers](../find-phone-numbers/)). Search rows carry no email, so the
email lookup runs as a separate stage off the person's own LinkedIn profile, and a separate
deliverability check keeps only verified addresses. **One API key.**

- The people-database search is a **beta surface Limadata enables per account**. If your key is
  otherwise valid but people search returns nothing and the provider reports that database access
  is not enabled, ask Limadata to switch it on for your account — it is a plan setting, not a bad
  key.

### HarvestAPI
A LinkedIn lead-search provider with **no email product** — it returns people, their LinkedIn
profile and their current job title, and nothing else. Title and country are filtered at source;
city is matched after fetch, because LinkedIn's location facet ORs its values, so sending a city
alongside a country would widen the result set rather than narrow it. No skills filter, no headline,
no mobile. **One API key.**

- Because no address ever comes back, a project with **"Email is required"** on won't spend
  anything against HarvestAPI. Pair it with a different provider if you need emails.
- It scopes a search by **LinkedIn company page only** — a company with no LinkedIn page cannot be
  searched at all, which is the opposite of {% include provider-link.html name="Anymail Finder" cost=false %}'s domain-only lookup.

### Wiza
Title, country, city and skills all run **at source**, so nothing is fetched and then discarded.
Returns LinkedIn profile but no headline, and **mobile phone numbers** (see
[Find phone numbers](../find-phone-numbers/)). Email and phone are separate asynchronous *reveals*
(a short poll) that bill only when something comes back. **One API key.**

- SignalsAPI spends Wiza's **API credits**, which you buy one-off — they are a different meter from
  the per-seat email/phone allowances on the subscription plans, and they do not expire. You do not
  need to be on an API plan to buy them.

### BetterContact
A waterfall aggregator: one lookup fans out across 20+ upstream data vendors at request time, so
nothing comes from a stored snapshot. Title, country, skills, **department** and **seniority** all
run **at source**; there is **no city filter** — its location facet is country-level only, and the
people it returns carry no city to match afterwards. Returns LinkedIn profile **and headline**, plus
**mobile phone numbers** (see [Find phone numbers](../find-phone-numbers/)). Search rows carry no
contact data, so email and phone are separate asynchronous lookups (a short poll, typically half a
minute or more). Resolves people from the company **domain** — no LinkedIn page needed. **One API
key.**

- Email costs **1 credit** and a phone number **10 credits**, charged only when the result is
  valid — an undeliverable or catch-all address costs nothing, so a retry after a miss is free.
- Only fully deliverable addresses count as verified; a catch-all domain accepts every address, so
  those are not kept.
- The people search itself drew no credits when SignalsAPI measured it (2026-08-19), but
  BetterContact publishes no price for it, so treat that as an observation rather than a promise.
- **Seniority** and **department** are picked from BetterContact's own fixed lists in the persona
  form (seniority runs from intern through c-suite, partner, owner and founder).

### Mindcase
A LinkedIn company-employees search with **no email product** — it returns people, their LinkedIn
profile, **headline** and current job title, but never an address or a phone number. Title, country
and city all run **at source** (country and city go to the vendor as one location list). No skills,
department or seniority. **One API key.**

- Because no address ever comes back, a project with **"Email is required"** on won't spend
  anything against Mindcase. Pair it with a different provider if you need emails.
- It scopes a search by **LinkedIn company page only** — a company with no LinkedIn page cannot be
  searched at all.
- Billing is per profile returned, from prepaid usage rather than a plan or seat.

## How to choose

- **You want mobile numbers** → {% include mobile-providers.html bold=true joiner="or" %}.
- **You filter by country or city** → **People Data Labs**, **Limadata**, **Wiza** or **Mindcase**
  (the four that do both at source).
  Icypeas, {% include provider-link.html name="Prospeo" cost=false %}, LeadMagic and HarvestAPI can still filter location, but after fetch (extra spend).
  **BetterContact** filters country at source but cannot filter by city.
- **You target by department / seniority** → **Hunter** or **BetterContact** (department +
  seniority) or **Tomba** (department) — filtered at source, so precise and credit-efficient.
- **You want LinkedIn headlines for AI-written outreach** → **Icypeas**, **People Data Labs**,
  **Limadata**, **BetterContact**, **Mindcase**, or **{% include provider-link.html name="Prospeo" cost=false %}**.
- **You have domain-only companies (no LinkedIn page)** → **{% include provider-link.html name="Anymail Finder" cost=false %}** — it resolves the
  decision maker from the company domain alone — or **BetterContact**, which also keys on the
  domain. **HarvestAPI** and **Mindcase** are the ones to avoid here: they can only search a company
  that has a LinkedIn page.
- **You need email addresses** → any provider except **HarvestAPI** and **Mindcase**, which have no
  email product.
- **You already have an account somewhere** → just connect it; all of them except **HarvestAPI** and
  **Mindcase** cover the core people + verified-email job.

Not sure which fits? Start a trial with one provider, run a search, and check the
**fetched-vs-disqualified** breakdown on your leads — it shows exactly how many people were fetched
and why any were dropped, so you can see result quality and credit use before committing.

See also: [Bring your own people-data provider](../bring-your-own-people-provider/) ·
[Find decision makers](../find-decision-makers/) · [Find phone numbers](../find-phone-numbers/)
