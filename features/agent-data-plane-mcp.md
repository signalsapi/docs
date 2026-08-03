---
title: Agent data plane — MCP server
parent: Features
layout: default
verified_on: 2026-08-03
owner: mykola
redirect_from: "/features/agent-data-plane-mcp.html"
nav_order: 19
page_type: feature
description: The agent data plane's MCP tool contract — code-complete, not yet hosted at a public endpoint.
prereq: mcp_hosting
---

# Agent data plane — MCP server

{% include prereq.html %}

The [Model Context Protocol](https://modelcontextprotocol.io) is how an AI agent discovers and calls
tools. The plane ships an MCP server, `signalsapi-plane`, that exposes the hiring-panel primitives as
agent tools — the same data, the same metering, and the same key as the
[REST API](../agent-data-plane-api/).

Where a REST client has to know which URL to build, an MCP agent sees eight tools with typed
arguments and picks one at reasoning time.

## Status: not hosted yet

The server is code-complete but **not yet deployed to an endpoint you can connect to** — there is no
public base URL, and nothing below claims otherwise. What you can do today is run it yourself: the
source is committed under `mcp/` in this repository, and it proxies every tool call to a REST base
URL you control — by default the [local mock](../agent-data-plane-mock/) from your own machine, so the
whole stack runs with no key and no hosted endpoint.

Want to be first in line once the real MCP surface is hosted? Tell [Support](/support/) what you're
building — that is not a prerequisite for anything above, just a signal that moves it up the queue.
In the meantime every tool below has an exact REST equivalent that
works today.

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
3. **Prospect** with `who_is_hiring_for` when you have a role and a geography but no company yet.
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
