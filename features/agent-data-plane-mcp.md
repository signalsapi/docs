---
title: Agent data plane — MCP server
parent: Features
layout: home
nav_order: 11.2
---

# Agent data plane — MCP server

The [Model Context Protocol](https://modelcontextprotocol.io) is how an AI agent discovers and calls
tools. The plane ships an MCP server, `signalsapi-plane`, that exposes the hiring-panel primitives as
agent tools — the same data, the same metering, and the same key as the
[REST API](agent-data-plane-api).

Where a REST client has to know which URL to build, an MCP agent sees eight tools with typed
arguments and picks one at reasoning time.

## Status: not hosted yet

The server is code-complete but **not yet deployed to an endpoint you can connect to**, so there is
no connect snippet on this page. Publishing one before the endpoint exists would be inventing a URL.

This page documents the tool contract so you can plan an integration now.
[Email us](mailto:mykola@signalsapi.com) if you want the MCP surface hosted — knowing someone is
waiting on it is what moves it up the queue. In the meantime every tool below has an exact REST
equivalent that works today.

## Authentication

MCP tool calls carry no HTTP headers, so the key that the REST surface passes as `X-API-Key` is
instead a **tool argument**, `plane_api_key`, on every tool. It resolves to the same per-customer key
and enforces the same tenant isolation; an unknown or revoked key fails the call.

Treat it like any other secret your agent holds: inject it from a secret manager at tool-call time,
never inline it into a prompt.

---

## The tools

| Tool | Arguments | REST equivalent |
|---|---|---|
| `is_hiring` | `company_id` | [`GET /v1/companies/{id}/is-hiring`](agent-data-plane-api#is-this-company-hiring) |
| `get_open_reqs` | `company_id`, `function?`, `country?`, `limit?` | [`GET /v1/companies/{id}/open-reqs`](agent-data-plane-api#open-requisitions) |
| `hiring_pulse` | `company_id`, `max_age?` | [`GET /v1/companies/{id}/hiring-pulse`](agent-data-plane-api#hiring-pulse) |
| `who_is_hiring_for` | `role?`, `geo?`, `since?`, `cursor?`, `limit?` | [`GET /v1/reqs/search`](agent-data-plane-api#who-is-hiring-for-a-role) |
| `pre_action_brief` | `company_id`, `max_age?` | [`GET /v1/companies/{id}/pre-action-brief`](agent-data-plane-api#pre-action-brief) |
| `get_changes` | `since`, `company_id?`, `event_type?`, `limit?` | [`GET /v1/events`](agent-data-plane-api#poll-for-changes) |
| `watch_company` | `company_id`, `event_types`, `webhook_endpoint_id` | [`POST /v1/watches`](agent-data-plane-api#watch-a-company) |
| `write_outcome` | `company_id`, `outcome`, `observed_at`, `req_key?` | [`POST /v1/companies/{id}/outcomes`](agent-data-plane-api#record-an-outcome) |

Every tool also takes `plane_api_key`. Arguments marked `?` are optional and share the REST defaults.

Each tool returns the same JSON shape its REST counterpart serializes — provenance envelopes and all.
No business logic is reimplemented behind the MCP surface; both entry points call the same code, so
the two can never drift.

---

## How an agent uses them

The tools are designed to be composed cheaply-first, expensively-last:

1. **Qualify** with `is_hiring` — one cheap `call` unit tells you whether the company is worth any
   further spend.
2. **Understand** with `hiring_pulse`, or skip straight to `pre_action_brief` when you are about to
   act and want the whole picture in one round-trip.
3. **Prospect** with `who_is_hiring_for` when you have a role and a geography but no company yet.
4. **Stay current** with `get_changes` — replay the cursor rather than re-reading company endpoints
   on a timer. It bills per event returned, so an unchanged world costs nothing.
5. **Close the loop** with `write_outcome` so the plane learns what actually converted.

`hiring_pulse` and `pre_action_brief` accept `max_age` (seconds) and are billed accordingly. When the
company is cold and you declared a `max_age`, they return `{"job_id": …, "status": "crawling"}`
rather than blocking — queue it, do something else, ask again shortly.

See [Tiers and metering](agent-data-plane#tiers-and-metering) for exactly how each call bills.

---

## Where to go next

- **[REST API reference](agent-data-plane-api)** — every tool above, callable over HTTP today
- **[Agent data plane overview](agent-data-plane)** — the ledger, the tiers, getting access
