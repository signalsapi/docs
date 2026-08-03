---
title: Agent data plane — MCP server
parent: APIs
layout: default
verified_on: 2026-08-03
owner: mykola
redirect_from: "/features/agent-data-plane-mcp.html"
nav_order: 4
page_type: feature
description: The agent data plane's MCP tool contract — a local stdio server, waiting on the plane's base URL and key.
prereq: plane_access
---

# Agent data plane — MCP server

{% include prereq.html %}

The [Model Context Protocol](https://modelcontextprotocol.io) is how an AI agent discovers and calls
tools. The plane ships an MCP server, `signalsapi-plane`, that exposes the hiring-panel primitives as
agent tools — the same data, the same metering, and the same key as the
[REST API](../agent-data-plane-api/).

Where a REST client has to know which URL to build, an MCP agent sees {{ site.data.mcp_tools.items | size }} tools with typed
arguments and picks one at reasoning time.

## Status: local by design, waiting on plane access

`signalsapi-plane` is a **stdio server**: your MCP client spawns it as a subprocess and talks to it
over stdin and stdout, exactly as the connect snippet below shows. That is the ordinary shape for an
MCP server, and it is not a temporary arrangement — there is no public MCP endpoint to connect to,
and there will not be one. The server runs on your machine before the plane opens and after it.

What is missing is the same thing the [REST API](../agent-data-plane-api/) is waiting on: the plane
is not yet open for self-serve signup and has **no public base URL**. The server is a thin proxy —
every tool call becomes a REST request against `PLANE_MCP_BASE_URL` — so until a base URL and key are
issued, point it at the [local mock](../agent-data-plane-mock/) and the whole stack runs on your own
machine with no key. The source is committed under `mcp/` in this repository.

On the day access is issued, nothing about the setup below changes: set `PLANE_MCP_BASE_URL` to the
issued base URL and pass the issued key as the `plane_api_key` argument.

Want to be first in line? Tell [Support](/support/) what you're building — that is not a prerequisite
for anything above, just a signal that moves it up the queue. In the meantime every tool below has an
exact REST equivalent, runnable now against the
[fixture gallery](../agent-data-plane-fixtures/) or the local mock.

## Run it yourself

1. **Start the local mock** (see [Run the specification as a local mock](../agent-data-plane-mock/)):

   ```bash
   npx @stoplight/prism-cli@5.16.0 mock openapi/plane-v1.yaml
   ```

2. **Install the server's dependencies**, from the repository root:

   ```bash
   cd mcp && npm install
   ```

3. **Point your MCP client at it.** For a client that reads a `mcpServers` block (for example,
   Claude Desktop's config file):

   ```json
   {
     "mcpServers": {
       "signalsapi-plane": {
         "command": "node",
         "args": ["/absolute/path/to/mcp/server.js"],
         "env": {
           "PLANE_MCP_BASE_URL": "http://127.0.0.1:4010"
         }
       }
     }
   }
   ```

Every tool call is forwarded as a REST request to `PLANE_MCP_BASE_URL` — point it at a real base URL
and pass a real key as the `plane_api_key` argument once one is issued, and nothing else changes.

## Authentication

MCP tool calls carry no HTTP headers, so the key that the REST surface passes as `X-API-Key` is
instead a **tool argument**, `plane_api_key`, on every tool. It resolves to the same per-customer key
and enforces the same tenant isolation; an unknown or revoked key fails the call.

Treat it like any other secret your agent holds: inject it from a secret manager at tool-call time,
never inline it into a prompt.

---

## The tools

This table is generated from `openapi/plane-v1.yaml`'s `x-mcp-tool` operations, not hand-typed — the
`mcp-tool-table-generated` assertion fails the build if it ever drifts from the specification.

| Tool | Arguments | REST equivalent |
|---|---|---|
{%- for item in site.data.mcp_tools.items %}
| `{{ item.tool }}` | {% for a in item.args %}`{{ a }}`{% unless forloop.last %}, {% endunless %}{% endfor %} | [`{{ item.method }} {{ item.path }}`](../agent-data-plane-api/#{{ item.summary | slugify }}) |
{%- endfor %}

Every tool also takes `plane_api_key`. Arguments marked `?` are optional and share the REST defaults.

Every **metered** tool additionally accepts an optional `idempotency_key` argument — the header-less
transport's equivalent of the REST [`Idempotency-Key`](../agent-data-plane-api/#idempotency) header, with
identical semantics: reuse the same value on a retry and the call bills exactly once within a fixed
24h window, namespaced per key and per tool. `write_outcome` is a write-back rather than a metered
read, so it does not take one.

Each tool returns the same JSON shape its REST counterpart serializes — provenance envelopes and all.
No business logic is reimplemented behind the MCP surface: every tool above proxies the identical REST
operation, generated from the same `x-mcp-tool` set as the table above, not hand-counted:
{%- assign plane_ops = site.data.plane_status.items -%}
{%- assign mcp_op_count = plane_ops | where_exp: "op", "op.mcp_tool" | size -%}
{%- assign total_op_count = plane_ops | size -%}
{%- assign rest_only_count = total_op_count | minus: mcp_op_count -%}
MCP exposes {{ mcp_op_count }} of {{ total_op_count }} operations; {{ rest_only_count }} are REST-only.

---

## How an agent uses them

The tools are designed to be composed cheaply-first, expensively-last:

1. **Qualify** with `is_hiring` — one cheap `call` unit tells you whether the company is worth any
   further spend.
2. **Understand** with `hiring_pulse`, or skip straight to `pre_action_brief` when you are about to
   act and want the whole picture in one round-trip.
3. **Prospect** with `who_is_hiring_for` when you have a role and a geography but no company yet — or
   `search_jobs` for the same matches as a flat, one-row-per-role list instead of grouped by company.
4. **Stay current** with `get_changes` — replay the cursor rather than re-reading company endpoints
   on a timer. It bills per event returned, so an unchanged world costs nothing.
5. **Close the loop** with `write_outcome` so the plane learns what actually converted.

`hiring_pulse` and `pre_action_brief` accept `max_age` (seconds) and are billed accordingly. When the
company is cold and you declared a `max_age`, they return `{"job_id": …, "status": "crawling"}`
rather than blocking — queue it, do something else, ask again shortly.

See [Tiers and metering](../agent-data-plane/#tiers-and-metering) for exactly how each call bills.

---

## Where to go next

- **[REST API reference](../agent-data-plane-api/)** — every tool above, callable over HTTP today
- **[Agent data plane overview](../agent-data-plane/)** — the ledger, the tiers, getting access

{% include recent-changes.html %}
