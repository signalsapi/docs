---
title: Agent data plane — Clay integration
parent: APIs
layout: default
verified_on: 2026-08-03
owner: mykola
redirect_from: "/features/agent-data-plane-clay.html"
nav_order: 5
page_type: feature
description: Add a Clay enrichment column that returns a company's hiring motion as flat, filterable rows.
prereq: plane_access
---

# Agent data plane — Clay integration

**Not what you're looking for?** This page pulls company hiring data *into* a Clay table (an
enrichment column). To push your SignalsAPI leads *out* to Clay instead, see
[Integrating with Clay](/features/integrations/#integrating-with-clay).

{% include prereq.html %}

Clay lets you add an enrichment column backed by any HTTP endpoint. The plane ships one built for
exactly that: give it a company domain, get back that company's hiring motion as flat columns you can
filter, sort and run playbooks on.

One row in, one row out — no pagination, no cursors, no provenance envelopes to unwrap.

## What you get

For each company, a single flat object:

| Column | Type | Meaning |
|---|---|---|
| `company_id` | number | The plane's id for the company — use it against the [REST API](../agent-data-plane-api/) |
| `name` | string | Company name |
| `domain` | string | Company domain |
| `hq_country` | string | Headquarters country |
| `boards` | list | ATS and job boards we observe them on |
| `is_hiring` | boolean | Whether they have any active requisition |
| `open_req_count` | number | How many |
| `new_roles_30d` | number | Roles opened in the last 30 days |
| `velocity` | number | Rate of change in open requisitions |
| `direction` | string | `up`, `down`, or `flat` |
| `is_surge` | boolean | True when both new-roles and velocity cross their thresholds |
| `as_of` | timestamp | When this answer was true |

`is_surge` is the one to build a playbook on: it fires when a company is not merely hiring, but
hiring *harder than it was*.

---

## Setting it up

The plane is not yet self-serve, so there is no base URL to point Clay at yet. You do not need one to
plan the column: the fixture at
[`/fixtures/v1/clay-enrich.json`](/fixtures/v1/clay-enrich.json) is this exact response shape, and the
[local mock](../agent-data-plane-mock/) runs the full request/response cycle before you have a key.
Want to be first in line once self-serve opens? Tell [Support](/support/) what you're building.

Once you have a key and a base URL, in Clay:

1. Add an **HTTP API** enrichment column to your table.
2. Set the method to **POST** and the URL to `{YOUR_BASE_URL}/v1/clay/enrich`.
3. Add a header — name `X-API-Key`, value your plane key.
4. Add a header — name `Content-Type`, value `application/json`.
5. Set the body to map your table's domain column:

   ```json
   { "domain": "{{ Domain }}" }
   ```

6. Run the column. Each row resolves independently.

### Matching by name instead

If you only have company names, send `name` instead of `domain`:

```json
{ "name": "{{ Company }}" }
```

You may send both. `domain` is matched first because it is unambiguous; `name` falls back to an
exact case-insensitive match and then a normalized one. Domain matching is strongly preferred —
names collide, domains do not.

---

## Trying it outside Clay

The same endpoint over curl, to sanity-check your key before wiring up a column:

```bash
curl -X POST \
  -H "X-API-Key: $PLANE_API_KEY" \
  -H 'Content-Type: application/json' \
  -d '{"domain": "zollsoft.de"}' \
  "$PLANE_BASE_URL/v1/clay/enrich"
```

```json
{
  "company_id": 4412,
  "name": "zollsoft GmbH",
  "domain": "zollsoft.de",
  "hq_country": "DE",
  "boards": ["greenhouse"],
  "is_hiring": true,
  "open_req_count": 7,
  "new_roles_30d": 3,
  "velocity": 0.1,
  "direction": "up",
  "is_surge": false,
  "as_of": "2026-07-08T04:11:07Z"
}
```

## When a company doesn't resolve

A domain or name we have never observed returns `404`. In Clay that surfaces as an empty cell rather
than a failed run — the rest of your table keeps enriching.

That is a real answer, not an error: it means the company has no ATS or job-board presence we track,
which is itself a useful filter.

---

## Billing

One `call` unit per row, billed at class `cached` — the same as any
[Tier 0 read](../agent-data-plane/#tiers-and-metering). Re-running a column re-bills it.
[`GET /v1/usage`](../agent-data-plane-api/#usage) shows your rolling totals.

## Where to go next

- **[Agent data plane overview](../agent-data-plane/)** — the ledger, the tiers, getting access
- **[REST API reference](../agent-data-plane-api/)** — go deeper than one flat row per company
