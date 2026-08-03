---
title: Agent data plane — fixture gallery
parent: Features
layout: default
verified_on: 2026-08-03
owner: mykola
nav_order: 17
page_type: feature
description: "One runnable curl command per plane operation, each pointed at a recorded fixture on this origin — no key, no backend, no waiting for access."
---

# Agent data plane — fixture gallery

Every command below is real: paste it into a terminal and it returns the exact recorded response
shown beneath it — no `X-API-Key` header, no base URL, and no waiting on [Support](/support/). Each
fixture is a static file, checked against [`openapi/plane-v1.yaml`](/openapi/plane-v1.yaml)'s schema
for the operation it stands in for. The [REST reference](/features/agent-data-plane-api/) shows the
real request shape once you have a key. For the write operations, or anything more interactive than a
fetch, [run the specification as a local mock](../agent-data-plane-mock/) instead.

`revokeKey` (`DELETE /v1/keys/{key_id}`) and `cancelWatch` (`DELETE /v1/watches/{watch_id}`) return
`204` with no body, so neither has a fixture here.

## Your account

### Who am I

`GET /v1/whoami`

```bash
curl {{ site.url }}/fixtures/v1/whoami.json
```

### Issue a key

`POST /v1/keys`

```bash
curl {{ site.url }}/fixtures/v1/issue-key.json
```

### Usage

`GET /v1/usage`

```bash
curl {{ site.url }}/fixtures/v1/get-usage.json
```

## Tier 0 — cached reads

### Is this company hiring?

`GET /v1/companies/{company_id}/is-hiring`

```bash
curl {{ site.url }}/fixtures/v1/is-hiring.json
```

### Open requisitions

`GET /v1/companies/{company_id}/open-reqs`

```bash
curl {{ site.url }}/fixtures/v1/get-open-reqs.json
```

### Company enrichment

`GET /v1/companies/{company_id}/enrichment`

```bash
curl {{ site.url }}/fixtures/v1/get-enrichment.json
```

### First hire in a function

`GET /v1/companies/{company_id}/first-hire`

```bash
curl {{ site.url }}/fixtures/v1/get-first-hire.json
```

### Repost pain

`GET /v1/companies/{company_id}/repost-pain`

```bash
curl {{ site.url }}/fixtures/v1/get-repost-pain.json
```

### ATS migrations

`GET /v1/companies/{company_id}/ats-migrations`

```bash
curl {{ site.url }}/fixtures/v1/get-ats-migrations.json
```

### Who is hiring for a role?

`GET /v1/reqs/search`

```bash
curl {{ site.url }}/fixtures/v1/search-reqs.json
```

### Market role demand

`GET /v1/markets/role-demand`

```bash
curl {{ site.url }}/fixtures/v1/get-market-role-demand.json
```

## Tier 1 — freshness-aware reads

### Hiring pulse

`GET /v1/companies/{company_id}/hiring-pulse`

```bash
curl {{ site.url }}/fixtures/v1/get-hiring-pulse.json
```

### Pre-action brief

`GET /v1/companies/{company_id}/pre-action-brief`

```bash
curl {{ site.url }}/fixtures/v1/get-pre-action-brief.json
```

## The change feed

### Poll for changes

`GET /v1/events`

```bash
curl {{ site.url }}/fixtures/v1/get-changes.json
```

### Register a webhook

`POST /v1/webhooks`

```bash
curl {{ site.url }}/fixtures/v1/register-webhook.json
```

### Watch a company

`POST /v1/watches`

```bash
curl {{ site.url }}/fixtures/v1/watch-company.json
```

## Writing back

### Record an outcome

`POST /v1/companies/{company_id}/outcomes`

```bash
curl {{ site.url }}/fixtures/v1/record-outcome.json
```

### Clay enrichment

`POST /v1/clay/enrich`

```bash
curl {{ site.url }}/fixtures/v1/clay-enrich.json
```
