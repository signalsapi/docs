---
title: Agent-builder quickstart
parent: Quick start
layout: default
nav_order: 3
page_type: task
description: Build an agent data plane integration today, against the reference's own example payloads.
---

# Agent-builder quickstart

## Before you start

The agent data plane is not yet open for self-serve signup and has no public base URL or issued
key today — see [Agent data plane](/features/agent-data-plane/). You do not need either to start
building: every operation's request and response shape is already fully documented, with real
example payloads, in the [REST API reference](/features/agent-data-plane-api/).

## Steps

1. **Read the operation's documented shape.**

   ```bash
   curl https://docs.signalsapi.com/features/agent-data-plane-api/
   ```

   Find the operation you need — for example `GET /v1/companies/{company_id}/hiring-pulse` — and
   its example response.

2. **Copy that example response into a local file**, e.g. `fixtures/hiring-pulse.json`. The
   reference's examples are the real, committed payload shape — not placeholders — so what you
   parse today is what a live response will look like.

3. **Build your integration against that local file** instead of a live endpoint: point your HTTP
   client or MCP tool stub at `fixtures/hiring-pulse.json` and write your parsing, provenance-envelope
   handling, and `as_of` logic against it.

4. **Repeat for every operation you need**, one local fixture file per operation, until the plane
   publishes a specification and recorded fixtures on this documentation origin — at which point
   the same shapes you built against move from a local file to a real URL with no reshaping
   required.

## Check it worked

Your integration correctly reads every field in the example payload you copied — including the
provenance envelope on the four history-backed reads and the shared `as_of` timestamp on every
read — and handles the `202 {"job_id": …, "status": "crawling"}` shape the plane returns for a
cold company.

## If it did not work

If a field in your local fixture doesn't match what the [REST API reference](/features/agent-data-plane-api/)
documents, the reference is the source of truth — re-copy the example payload. For anything the
reference doesn't answer, check [Is it working?](/is-it-working/) or the [FAQ](/faq/).
