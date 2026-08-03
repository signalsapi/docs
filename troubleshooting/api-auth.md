---
title: API authentication error
parent: Troubleshooting
layout: default
verified_on: 2026-08-02
owner: mykola
nav_order: 6
page_type: symptom
search_aliases:
  - api authentication error
  - 401 unauthorized
  - 403 forbidden
  - invalid api key
  - authorization error
description: Every REST and agent data plane error status code, its real cause, and the fix.
---

# API authentication error

## What you are seeing

A request to the REST API or the agent data plane returns an error status instead of data.

## Most likely cause

Your request is missing its authentication header, or the key in it is wrong. This looks the same
either way — a `403` on the self-serve REST API, or a `401` on the agent data plane — because both
mean the request never got past authentication. See [API access](/features/api-access/) and
[Agent data plane — REST API](/features/agent-data-plane-api/).

## Check this first

Compare your response's status code against this table:

| Code | Meaning | Fix |
|---|---|---|
| `401` | No `X-API-Key` header at all (agent data plane only) | Add the `X-API-Key` header to every request |
| `403` | Missing, invalid, expired, deactivated, or revoked key | Check the key's value and status in **Settings → API Key**, or reconnect it in **Settings → Provider** for the agent data plane |
| `404` | The project, company, key, watch, or webhook isn't yours, or doesn't exist | Double-check the id in your URL — the API never reveals whether a resource exists if it isn't yours |
| `422` | An unsupported `format` value on the export endpoint | Use `format=json` or `format=csv` |

## Other causes

- **You're using the wrong header for the wrong API.** The self-serve REST API expects
  `Authorization: Bearer YOUR_API_KEY`; the agent data plane expects `X-API-Key: YOUR_API_KEY` —
  they are not interchangeable. See [API access](/features/api-access/) and
  [Agent data plane](/features/agent-data-plane/).
- **Your key was regenerated or revoked**, and you're still using the old value. Get the current
  one from **Settings → API Key**, or mint a new plane key via
  [`POST /v1/keys`](/features/agent-data-plane-api/#issue-a-key).

## Still stuck

Check [Is it working?](/faq/#is-it-working) or contact
[Support](/support/) with the status code and endpoint you're
calling (never your key).
