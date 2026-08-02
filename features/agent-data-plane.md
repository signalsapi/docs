---
title: Agent data plane
parent: Features
layout: default
nav_order: 17
page_type: feature
prereq: plane_access
description: A machine-facing surface reporting what changed in a company's hiring activity, not just what's posted now.
---

# Agent data plane

{% include prereq.html %}

Most hiring data tells you what is posted **right now**. The agent data plane tells you what
**changed** — and when, and how often, and whether it has happened before.

It is a machine-facing surface built for AI agents and automated workflows rather than for people
clicking around the app. Two ways in, over the same data and the same key:

- a **[REST API](../agent-data-plane-api/)** at `/v1`
- an **[MCP server](../agent-data-plane-mcp/)** exposing the same primitives as agent tools

Plus a **[Clay HTTP provider](../agent-data-plane-clay/)**, so Clay can call SignalsAPI as an
enrichment column in your table.

---

## The hiring-events ledger

Underneath everything is an append-only **ledger of hiring events**. Every time we observe a
requisition on a company's ATS or job board, we write an event rather than overwriting a row. Nothing
is ever silently mutated, so the history stays intact and queryable.

Every event is one of three types:

| Event type | Meaning |
|---|---|
| `opened` | A requisition we have never seen before |
| `reposted` | The same requisition appearing again after a gap |
| `reobserved` | The same requisition still present, seen again |

That distinction is the whole point. A job that is `reposted` three times is a role the company
cannot fill — a very different signal from one that is merely still `reobserved`. Because the ledger
is append-only, you get a **longitudinal panel**: not a snapshot of the job market, but its motion.

The primitives built directly on that history:

| Primitive | Question it answers |
|---|---|
| **Hiring pulse** | Is this company's hiring speeding up or slowing down? Is it surging? |
| **First hire** | When did this company open its *first ever* role in a function? (a new budget line) |
| **Repost pain** | Which roles has this company failed to fill, ranked by how often it reposted them? |
| **ATS migrations** | Has this company switched applicant-tracking vendors, and when? |
| **Role demand** | Market-wide: how has demand for this role, in this geography, moved over time? |
| **Change feed** | What has changed since the last time I asked? (a replayable cursor) |

---

## Reading the data honestly

Two things the plane will never do: fabricate a timestamp, or quietly serve you something older than
it claims.

Every company and market read carries an **`as_of`**. On the four history-backed reads —
`hiring-pulse`, `first-hire`, `repost-pain` and `ats-migrations` — each headline value additionally
arrives inside a *provenance* envelope naming the board it came from, when it was observed, and a
confidence score. Reads that return plain scalars (`is-hiring`, `open-reqs`, `enrichment`) carry the
shared `as_of` instead.

Those same reads set two HTTP headers:

| Header | What it tells you |
|---|---|
| `X-Data-Freshness` | The real observation time of the underlying data |
| `X-Meter-Class` | How the read was **billed** — `cached` or `fresh` |

`X-Meter-Class` is a billing classification, **not** a freshness claim. Read `X-Data-Freshness` when
you want to know how old the data actually is.

---

## Tiers and metering

Endpoints fall into two groups by how they are metered.

**Tier 0 — cached reads.** Billed one `call` unit each. These are not rate-limited by call volume;
they are floored on **data freshness**. Data that is fresher than the floor is withheld until it ages
past it, rather than being served with a rewritten timestamp. Ask as often as you like — you will see
the market as it stood a defined interval ago.

**Tier 1 — freshness-aware reads.** `hiring-pulse` and `pre-action-brief` accept a `max_age`
(seconds). Declare it and the plane will meet it, or tell you honestly that it could not:

| Situation | You get | Billed |
|---|---|---|
| No `max_age` declared | Best available data | one `call`, class `cached` |
| `max_age` satisfied | Data within your window | one `call`, class `cached` |
| `max_age` declared but unmet, and we know the company | Best available data, labeled not-cache-fresh | one `call`, class `fresh` |
| `max_age` declared and we have no data on the company at all | `202 {"job_id": …, "status": "crawling"}` — a crawl is queued | one `forced_fresh` |

A `202` never blocks. It queues a priority crawl and hands you a `job_id`; poll the endpoint again
shortly after.

Four meter units are recorded: `call`, `change`, `watch` and `forced_fresh`.
[`GET /v1/usage`](../agent-data-plane-api/#usage) reports your rolling totals. Notably, the **change feed
bills per event returned, not per poll**: an empty page costs nothing, so you can poll it as tightly
as you like.

Free, paid, and enterprise packaging maps onto the Tier 0 / Tier 1 split above — Tier 0 cached reads
free, Tier 1 fresh reads paid, enterprise arrangements by conversation. Pricing is not yet published;
talk to us and we will quote your usage shape.

---

## Getting access

The plane is **not yet open for self-serve signup**, and there is no public base URL to point a
client at today. Access is arranged directly:

1. Contact [Support](/support/) describing what you want to build.
2. We issue your first API key and the base URL to use it against.
3. From then on you can mint and revoke additional keys yourself via
   [`POST /v1/keys`](../agent-data-plane-api/#issue-a-key), scoped to your own account.

Keys are shown **once**, at issuance, and stored only as a hash — we cannot recover one for you, so
put it straight into your secret manager. Every request is scoped to your own account: you can never
see, meter against, or revoke another customer's anything.

---

## Where to go next

- **[REST API reference](../agent-data-plane-api/)** — every endpoint, request and response shape
- **[MCP server](../agent-data-plane-mcp/)** — the same primitives as agent tools
- **[Clay integration](../agent-data-plane-clay/)** — SignalsAPI as an enrichment column in Clay

Looking for the API that reads **your projects and leads** out of the SignalsAPI app? That is a
different, self-serve API — see **[API access](../api-access/)**.
