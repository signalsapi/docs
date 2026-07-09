---
title: Agent data plane — REST API
parent: Features
layout: home
nav_order: 11.1
---

# Agent data plane — REST API

The full `/v1` reference. For what the plane *is* and how it is billed, start with the
[Agent data plane overview](agent-data-plane).

## Base URL

The plane is not yet open for self-serve signup and has **no public base URL**. Your base URL is
issued together with your first API key — [email us](mailto:mykola@signalsapi.com) to get set up.
The examples below assume you have exported it:

```bash
export PLANE_BASE_URL="…"   # issued with your first key
export PLANE_API_KEY="…"
```

## Authentication

Every request carries your key in the `X-API-Key` header:

```
X-API-Key: YOUR_API_KEY
```

| Situation | Response |
|-----------|----------|
| No `X-API-Key` header at all | `401` |
| Key is unknown, or has been revoked | `403` |
| A company, key, watch or webhook that isn't yours, or doesn't exist | `404` |

Unknown and revoked keys are deliberately indistinguishable. Every request is scoped to your own
`customer_id`: you can never read, meter against, or revoke another customer's anything.

## Response conventions

**`as_of`.** Every company and market read carries an `as_of` timestamp — the instant the answer
describes.

**The provenance envelope.** On the four history-backed reads (`hiring-pulse`, `first-hire`,
`repost-pain`, `ats-migrations`) each headline value arrives wrapped:

```json
{
  "value": 12,
  "source_board": "greenhouse",
  "observed_at": "2026-07-08T04:11:07Z",
  "confidence": 0.94
}
```

`source_board` and `observed_at` may be `null` when a value is an aggregate across boards rather than
a specific posting. The remaining reads (`is-hiring`, `open-reqs`, `enrichment`) return plain scalars
plus the shared `as_of`.

**Freshness and billing headers.** Every metered read sets both:

| Header | Meaning |
|---|---|
| `X-Data-Freshness` | The real observation time of the underlying data |
| `X-Meter-Class` | How this read was billed: `cached` or `fresh` |

They are **not** set on `202` cold-tail responses, nor on `/v1/events`, `/v1/whoami`, `/v1/usage`
or the key/webhook/watch management routes.

---

## Your account

### Who am I

```
GET /v1/whoami
```

What the presented key resolves to. Useful as a connectivity check.

```bash
curl -H "X-API-Key: $PLANE_API_KEY" "$PLANE_BASE_URL/v1/whoami"
```

```json
{ "customer_id": "acme", "tier": "paid", "plan": null, "scopes": [] }
```

### Issue a key

```
POST /v1/keys
```

Mint another key for **your own** account — the `customer_id` is always taken from the authenticated
caller, never from the request. The raw key is returned **once** and stored only as a hash; we cannot
recover it for you.

| Field | Notes |
|---|---|
| `tier` | The tier label recorded on the key (visible via `/v1/whoami`) |

```bash
curl -X POST -H "X-API-Key: $PLANE_API_KEY" -H 'Content-Type: application/json' \
  -d '{"tier": "paid"}' "$PLANE_BASE_URL/v1/keys"
```

```json
{ "id": 42, "key": "…shown once…", "customer_id": "acme", "tier": "paid" }
```

Returns `201`.

### Revoke a key

```
DELETE /v1/keys/{key_id}
```

Returns `204`. Revoking a key id that belongs to someone else returns `404` — identical to revoking
one that never existed.

### Usage

```
GET /v1/usage?window=24
```

Your metered usage over a rolling window, aggregated across **every key** your account holds.

| Query parameter | Default | Notes |
|---|---|---|
| `window` | `24` | Window size in **hours** |

```json
{
  "calls": 1840,
  "changes": 22791,
  "watches": 12,
  "forced_fresh": 3,
  "by_meter_class": { "cached": 1801, "fresh": 42 }
}
```

---

## Tier 0 — cached reads

Each bills one `call` unit at class `cached`, and is floored on data freshness (see
[Tiers and metering](agent-data-plane#tiers-and-metering)).

### Is this company hiring?

```
GET /v1/companies/{company_id}/is-hiring
```

The cheap qualifying gate — call it before spending on a richer read.

```bash
curl -H "X-API-Key: $PLANE_API_KEY" \
  "$PLANE_BASE_URL/v1/companies/4412/is-hiring"
```

```json
{ "is_hiring": true, "open_req_count": 7, "as_of": "2026-07-08T04:11:07Z" }
```

### Open requisitions

```
GET /v1/companies/{company_id}/open-reqs
```

The company's currently active reqs, **deduped across boards** — the same real job posted to two
boards appears once, with both boards listed.

| Query parameter | Default | Notes |
|---|---|---|
| `function` | — | Filter by function |
| `country` | — | Filter by country |
| `limit` | `50` | Page size |

```json
{
  "reqs": [
    {
      "title": "Senior Backend Engineer",
      "function": "engineering",
      "country": "DE",
      "first_seen": "2026-06-02T10:00:00Z",
      "boards": ["greenhouse", "linkedin"]
    }
  ],
  "as_of": "2026-07-08T04:11:07Z"
}
```

### Company enrichment

```
GET /v1/companies/{company_id}/enrichment
```

Basic firmographics derived from ATS and board sources. `404` when the company is unknown.

```json
{
  "name": "zollsoft GmbH",
  "domain": "zollsoft.de",
  "hq_country": "DE",
  "boards": ["greenhouse"],
  "as_of": "2026-07-08T04:11:07Z"
}
```

### First hire in a function

```
GET /v1/companies/{company_id}/first-hire
```

The earliest role the company ever opened per function — a new budget line. Optional `function`
narrows it to one. Values are provenance-wrapped.

```json
{
  "by_function": {
    "sales": { "value": "2026-03-14T09:00:00Z", "source_board": "role-slot", "observed_at": "2026-03-14T09:00:00Z", "confidence": 1.0 }
  },
  "as_of": "2026-07-08T04:11:07Z"
}
```

### Repost pain

```
GET /v1/companies/{company_id}/repost-pain
```

Reqs the company keeps failing to fill, hardest first. `repost_count` is provenance-wrapped.

```json
{
  "reqs": [
    {
      "title": "Staff SRE",
      "function": "engineering",
      "country": "US",
      "first_seen": "2026-01-08T12:00:00Z",
      "repost_count": { "value": 4, "source_board": "greenhouse", "observed_at": "2026-07-01T06:00:00Z", "confidence": 0.9 }
    }
  ],
  "as_of": "2026-07-08T04:11:07Z"
}
```

### ATS migrations

```
GET /v1/companies/{company_id}/ats-migrations
```

Applicant-tracking vendor switches, with a provenance-wrapped `occurred_at`.

```json
{
  "migrations": [
    {
      "from_vendor": "lever",
      "to_vendor": "greenhouse",
      "occurred_at": { "value": "2026-02-11T00:00:00Z", "source_board": "greenhouse", "observed_at": "2026-02-11T00:00:00Z", "confidence": 0.8 }
    }
  ],
  "as_of": "2026-07-08T04:11:07Z"
}
```

### Who is hiring for a role?

```
GET /v1/reqs/search
```

The reverse lookup: companies with active reqs matching a role and geography, deduped by company,
each with its full [hiring pulse](#hiring-pulse) and the specific reqs that matched.

| Query parameter | Default | Notes |
|---|---|---|
| `role` | — | Matches the req's function |
| `geo` | — | Matches the req's country |
| `since` | — | Only reqs first seen at or after this timestamp |
| `cursor` | — | Keyset cursor; pass the previous page's `next_cursor` |
| `limit` | `20` | Page size |

```json
{
  "companies": [
    { "company_id": 4412, "pulse": { "…": "…" }, "matched_reqs": [ { "…": "…" } ] }
  ],
  "next_cursor": 4412,
  "as_of": "2026-07-08T04:11:07Z"
}
```

Paginate by passing `next_cursor` back as `cursor` until it comes back `null`.

### Market role demand

```
GET /v1/markets/role-demand
```

Market-wide (not company-scoped) active-requisition demand over time, for a role and geography.

| Query parameter | Notes |
|---|---|
| `role` | Matches the req's function |
| `geo` | Matches the req's country |
| `since` | Lower bound on the series |

```json
{
  "series": [ { "bucket": "2026-06-01T00:00:00Z", "active_reqs": 318 } ],
  "as_of": "2026-07-08T04:11:07Z"
}
```

---

## Tier 1 — freshness-aware reads

Both routes below accept `max_age` (seconds) and are dual-metered against it. Omit `max_age` and you
get the best available data, billed `cached`. See the
[Tier 1 table](agent-data-plane#tiers-and-metering) for exactly how each case bills, including the
`202` cold-tail response.

### Hiring pulse

```
GET /v1/companies/{company_id}/hiring-pulse?max_age=3600
```

Velocity, direction and momentum in one call. The six headline values are provenance-wrapped;
`direction` is one of `up`, `down`, `flat`. `is_surge` is true when the company has crossed both the
new-roles and velocity thresholds.

```json
{
  "is_hiring":      { "value": true, "source_board": null, "observed_at": "…", "confidence": null },
  "open_req_count": { "value": 7,    "source_board": null, "observed_at": "…", "confidence": null },
  "new_roles_30d":  { "value": 3,    "source_board": null, "observed_at": "…", "confidence": null },
  "velocity":       { "value": 0.1,  "source_board": null, "observed_at": "…", "confidence": null },
  "direction":      { "value": "up", "source_board": null, "observed_at": "…", "confidence": null },
  "is_surge":       { "value": false,"source_board": null, "observed_at": "…", "confidence": null },
  "by_function":    { "engineering": 5, "sales": 2 },
  "momentum":       [ { "bucket_start": "2026-06-01T00:00:00Z", "open_req_count": 5 } ],
  "as_of": "2026-07-08T04:11:07Z"
}
```

When the company is cold and you declared a `max_age`, you get `202` instead:

```json
{ "job_id": 91823, "status": "crawling" }
```

### Pre-action brief

```
GET /v1/companies/{company_id}/pre-action-brief?max_age=3600
```

Everything an agent needs before acting on a company, pre-joined into **one** round-trip instead of
five: the pulse, first hires, repost pain, top open reqs, and ATS migrations. Built to be
token-shaped — every list is capped (top reqs 5, repost pain 5, momentum points 8, migrations 3)
regardless of how much history a company has.

Per-field provenance envelopes are stripped here — carrying one on every field would blow the token
budget this endpoint exists to bound — and replaced by a single `_provenance_summary` rollup.

```json
{
  "pulse": { "is_hiring": true, "open_req_count": 7, "new_roles_30d": 3, "velocity": 0.1,
             "direction": "up", "is_surge": false, "by_function": {"engineering": 5},
             "momentum": [ { "bucket_start": "…", "open_req_count": 5 } ] },
  "first_hires": { "sales": "2026-03-14T09:00:00Z" },
  "repost_pain": [ { "title": "Staff SRE", "function": "engineering", "country": "US",
                     "first_seen": "…", "repost_count": 4 } ],
  "top_reqs":    [ { "title": "Senior Backend Engineer", "function": "engineering",
                     "country": "DE", "first_seen": "…", "boards": ["greenhouse"] } ],
  "ats_migrations": [ { "from_vendor": "lever", "to_vendor": "greenhouse", "occurred_at": "…" } ],
  "_provenance_summary": { "as_of": "2026-07-08T04:11:07Z", "source_boards": ["greenhouse", "role-slot"] }
}
```

Cold behaves exactly as `hiring-pulse`: `202 {"job_id": …, "status": "crawling"}`.

---

## The change feed

### Poll for changes

```
GET /v1/events?since={cursor}
```

The ledger's diff feed: every event with `event_seq` greater than `since`, oldest first, plus a
`next_cursor` to replay from. This is the replacement for re-scraping — you ask what changed, not
what exists.

| Query parameter | Default | Notes |
|---|---|---|
| `since` | *(required)* | Return events after this `event_seq`. Start at `0` |
| `company_id` | — | Only this company's events |
| `event_type` | — | One of `opened`, `reposted`, `reobserved` |
| `limit` | `100` | Page size |

```bash
curl -H "X-API-Key: $PLANE_API_KEY" "$PLANE_BASE_URL/v1/events?since=0&limit=2"
```

```json
{
  "events": [
    {
      "event_seq": 1001,
      "company_id": 4412,
      "req_key": "greenhouse:zollsoft:senior-backend-engineer",
      "board": "greenhouse",
      "event_type": "opened",
      "observed_at": "2026-07-08T04:11:07Z",
      "function": "engineering",
      "country": "DE",
      "title": "Senior Backend Engineer",
      "source_board": "greenhouse",
      "confidence": 0.94
    }
  ],
  "next_cursor": 1001
}
```

Store `next_cursor` and pass it as the next `since`. The feed bills **one `change` unit per event
returned, independent of poll count** — an empty page costs nothing, so poll as tightly as you like.

### Register a webhook

```
POST /v1/webhooks
```

| Field | Notes |
|---|---|
| `url` | Where deliveries are POSTed |
| `secret` | Your HMAC signing key. Stored for signing, never logged, never returned |

```json
{ "id": 7, "url": "https://example.com/hooks/signalsapi" }
```

Returns `201`.

### Watch a company

```
POST /v1/watches
```

Subscribe a registered webhook to one company's hiring events. Bills one `watch` unit.

| Field | Notes |
|---|---|
| `company_id` | The company to watch |
| `event_types` | Any of `opened`, `reposted`, `reobserved` |
| `webhook_endpoint_id` | An `id` from `POST /v1/webhooks`, belonging to your account |

Returns `201 {"id": 15}`, or `404` when the webhook endpoint isn't yours.

### Cancel a watch

```
DELETE /v1/watches/{watch_id}
```

Returns `204`, or `404` when the watch isn't yours.

---

## Writing back

### Record an outcome

```
POST /v1/companies/{company_id}/outcomes
```

Tell the plane what happened after you acted — the substrate for outcome-aware scoring.

| Field | Notes |
|---|---|
| `outcome` | Your outcome label |
| `observed_at` | When it happened |
| `req_key` | Optional — ties the outcome to a specific requisition |

Returns `202 {"id": 88}`.

### Clay enrichment

```
POST /v1/clay/enrich
```

Documented separately, with setup steps, on the
**[Clay integration](agent-data-plane-clay)** page.

---

## Notes & limits

- **Your data only.** Every route filters by the authenticated key's `customer_id`. Another
  customer's key id, watch id or webhook id returns `404`, never their data.
- **Keys are shown once.** Only a hash is stored. Lose it and you mint a new one.
- **Cold reads never block.** A `202` queues a priority crawl and returns a `job_id` immediately;
  the request thread is never held open on a live crawl.
- **The change feed is the cheap path.** Polling `/v1/events` costs nothing when nothing changed —
  prefer it over re-reading company endpoints on a timer.
