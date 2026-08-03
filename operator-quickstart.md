---
title: Operator quickstart
parent: Quick start
layout: default
verified_on: 2026-08-02
owner: mykola
nav_order: 1
page_type: task
description: A first-session path from creating a search to a real project, using SignalsAPI's own screens.
---

# Operator quickstart

## Before you start

You need a SignalsAPI account — see [Quick start](/quick-start/) to register. Everything below
works on the free tier (company signals only); connecting a people-data provider key in
**Settings → Provider** additionally gets you decision-maker names and verified emails — see
[Bring your own people-data provider](/features/bring-your-own-people-provider/).

## Steps

1. **Create a search.** Go to **Search → Add Search** and enter the job titles or keywords you
   want to match — see [Advanced search](/features/advanced-search/) for search methods and
   filters.
2. **Set up a persona.** Go to **Personas** and create a new one. Write the job titles of the
   decision-makers you want to reach (e.g. `CEO`) — see [Find decision-makers](/features/find-decision-makers/).
3. **Connect a people-data provider (optional).** In **Settings → Provider**, choose a provider,
   paste its API key, and click **Save & validate** — see [Bring your own people-data provider](/features/bring-your-own-people-provider/).
4. **Open your project.** Open your [project list](https://app.signalsapi.com/leadlists/), add a
   new one or open an existing one, and let the search run — see [API access](/features/api-access/)
   for pulling the same data programmatically.

## Check it worked

Open the project you created in step 4. A working first session shows leads with a company and,
if you connected a provider, a decision-maker's name and email. The project's `usable_lead_count`
(visible via [API access](/features/api-access/)) is the number of leads that are actually ready
to use.

## If it did not work

If the project stays empty, start with [My project shows no leads](/troubleshooting/empty-results/).
If the Phone column is empty, see [My Phone column is blank](/troubleshooting/no-phone-numbers/).
If the same company shows up twice, see [The same company shows up twice](/troubleshooting/duplicates/).
If leads later stop reaching your CRM or outreach tool, see
[My integration stopped receiving leads](/troubleshooting/integration-stopped/). Otherwise start
with [Is it working?](/faq/#is-it-working) to rule out a platform-wide issue, then check the
[FAQ](/faq/). If neither explains it, contact [Support](/support/) with your search and persona
settings.

{% include recent-changes.html %}
