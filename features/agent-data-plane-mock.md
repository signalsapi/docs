---
title: Agent data plane — run the specification as a local mock
parent: Features
layout: default
verified_on: 2026-08-03
owner: mykola
nav_order: 23
page_type: task
description: "The one command that serves openapi/plane-v1.yaml locally, with responses matching the published fixtures."
---

# Agent data plane — run the specification as a local mock

The [fixture gallery](../agent-data-plane-fixtures/) is read-only: eighteen static files, one per
operation. For everything else — request validation, path parameters, the write operations, or just
poking at the shape of the API in a REPL — run the specification itself as a mock server.

## Before you start

You need Node.js (for `npx`) and this repository's [`openapi/plane-v1.yaml`](/openapi/plane-v1.yaml).
No key, no base URL, and nothing else to install ahead of time — `npx` fetches the mock tool on first
run.

## Steps

1. **Start the mock server** from the repository root:

   ```bash
   npx @stoplight/prism-cli@5.16.0 mock openapi/plane-v1.yaml
   ```

   This was verified against [Prism](https://github.com/stoplightio/prism) CLI version `5.16.0`. It
   starts a server on `http://127.0.0.1:4010` and logs every route it registered from the
   specification.

2. **Call it** like any other API — no headers required:

   ```bash
   curl http://127.0.0.1:4010/v1/whoami
   ```

## Check it worked

The response is the exact fixture, served locally:

```json
{ "customer_id": "acme", "tier": "paid", "plan": null, "scopes": [] }
```

Prism serves the `example:` block declared on each operation's response, and every operation with a
published fixture carries one byte-identical to it (minus the fixture's own `recorded_on` stamp).
`revokeKey` and `cancelWatch` are the two exceptions — both `204` with no body, so neither has a
fixture or an example to mirror, and Prism falls back to its own placeholder values for those two only.

## If it did not work

`command not found: npx` means Node.js isn't installed. `EADDRINUSE` means port `4010` is already
taken — pass `--port` with a different number. For anything else — including product behavior
unrelated to this mock — see [Troubleshooting](/troubleshooting/) or contact [Support](/support/).
