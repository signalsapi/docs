---
title: Find phone numbers
parent: Features
layout: default
verified_on: 2026-08-19
owner: mykola
redirect_from: "/features/find-phone-numbers.html"
nav_order: 8
stage: contact_enrichment
page_type: feature
prereq: mobile_phone_provider
description: How mobile phone numbers are looked up for decision-makers, and which providers support it.
---

# Find phone numbers

{% include prereq.html %}

Get a mobile phone number for each decision-maker alongside their email, so you can call or text directly without leaving your leads list.

{% assign mobile_providers = site.data.providers.items | where: "mobile_support", true %}
Phone lookup is powered by your connected [people-data provider](../bring-your-own-people-provider/). Mobile lookup is currently supported by: {% for p in mobile_providers %}**{% include provider-link.html name=p.name cost=false %}**{% unless forloop.last %}, {% endunless %}{% endfor %} — when you have a matching key saved, the option becomes available.

## Enable phone lookup on a project

Open your project's **Persona** settings and tick **Find phone numbers**.

{% include screenshot.html path="features/find-phone-numbers-1.png" width="720" %}

Phone lookup only runs when your connected provider supports it. If you select a provider that does not include mobile lookup the checkbox has no effect — no extra provider calls are made and no credits are spent.

## Phone numbers in your leads list

Once personation runs with the option enabled, a **Phone** column appears in your leads list.

{% include screenshot.html path="features/find-phone-numbers-2.png" width="720" %}

A dash (—) means the provider searched but found no number for that person. The lookup is on a best-effort basis — coverage depends on your provider's database.

## Lead detail page

The full phone number and its status are also shown on the individual lead page, alongside the rest of the person's contact information.

## CSV export

Phone numbers are included in the **Download CSV** export as the `contact_phone` column, appended after `req_url`.

```text
company,signal,source,observed_at,matched_on,contact_name,contact_title,linkedin_url,work_email,req_url,contact_phone
Acme,Head of Sales,linkedin,2026-08-01,title,Jane Doe,Head of Sales,https://linkedin.com/in/jane,jane@acme.com,https://acme.com/careers/123,+15551234567
Widget Co,VP Engineering,linkedin,2026-08-02,title,Bob Lee,VP Engineering,https://linkedin.com/in/bob,bob@widget.co,https://widget.co/careers/456,
```

An empty `contact_phone` cell means no number was found for that lead.

## Use phone in AI templates

The `{phone}` variable is available in any AI-generated field once a lead has a phone number. It's most useful for generating an SMS-ready opener or a CRM routing note:

```text
Draft a one-line SMS to {first_name} at {company_name} (hiring for {job_title}).
Their number is {phone}.
```

See [AI variables](../ai-variables/) for the full list.

## How it fits into the cost-staged pipeline

Phone lookup runs **after** email enrichment — you only spend provider credits on people who already passed AI qualification and (when required) have a verified email:

1. People search at the hiring company
2. AI qualification ranks and cuts the list
3. Email lookup for survivors *(when "Email is required" is on)*
4. **Phone lookup** for survivors *(when "Find phone numbers" is on)*

This keeps phone costs proportional to the leads you actually surface.

## Getting started

1. Go to **Settings → Provider** and save {% for p in mobile_providers %}a **{% include provider-link.html name=p.name cost=false %}** API key{% unless forloop.last %} or {% endunless %}{% endfor %}.
2. Open a project, go to **Persona**, and tick **Find phone numbers**.
3. Run personation — phone numbers appear in the leads list as results come in.

{% include recent-changes.html %}
