---
title: Statuses and error codes
parent: Troubleshooting
layout: default
nav_order: 8
page_type: reference
verified_on: 2026-08-02
owner: mykola
description: Every status string, error code, and response header the product emits, with its meaning and source.
---

# Statuses and error codes

Every machine-facing string, code, or header SignalsAPI emits, in one place — so the exact thing
you saw has a page, whichever screen or API response it came from.

## HTTP status codes

| Code | Meaning | Owning page |
|---|---|---|
| `401` | No `X-API-Key` header at all (agent data plane only) | [Agent data plane — REST API](/features/agent-data-plane-api/) |
| `403` | Missing, invalid, expired, deactivated, or revoked key | [API access](/features/api-access/), [Agent data plane — REST API](/features/agent-data-plane-api/) |
| `404` | The project, company, key, watch, or webhook isn't yours, or doesn't exist | [API access](/features/api-access/), [Agent data plane — REST API](/features/agent-data-plane-api/) |
| `422` | An unsupported `format` value on the export endpoint | [API access](/features/api-access/) |
| `201` | A new key was issued | [Agent data plane — REST API](/features/agent-data-plane-api/) |
| `202` | A cold-tail crawl was queued, or an outcome was recorded | [Agent data plane — REST API](/features/agent-data-plane-api/) |
| `204` | A key was revoked, or a watch was canceled | [Agent data plane — REST API](/features/agent-data-plane-api/) |

## Response headers

| Header | Meaning | Owning page |
|---|---|---|
| `X-Data-Freshness` | The real observation time of the underlying data | [Agent data plane](/features/agent-data-plane/) |
| `X-Meter-Class` | How the read was billed — `cached` or `fresh` | [Agent data plane](/features/agent-data-plane/) |

## Status strings and badges

| String | Meaning | Owning page |
|---|---|---|
| `active` | The connected people-data provider key is valid | [Bring your own people-data provider](/features/bring-your-own-people-provider/) |
| `invalid` | The connected people-data provider key was rejected | [Bring your own people-data provider](/features/bring-your-own-people-provider/) |
| Leads found | Decision-makers were found for a qualified company | [What's new](/whats-new/) |
| Qualified | A company matched your filters, but no decision-makers were found | [What's new](/whats-new/) |
| Searching... | Decision-maker search is still in progress | [What's new](/whats-new/) |
| Approved | You clicked Approve on a lead awaiting manual approval | [Integrations](/features/integrations/#approval-and-upload) |
| Uploaded | A lead was delivered to the integration destination | [Integrations](/features/integrations/#approval-and-upload) |
| `verified` | An `email_status` value: the email passed verification | [API access](/features/api-access/) |
| `opened` | A hiring requisition never seen before | [Agent data plane](/features/agent-data-plane/) |
| `reposted` | The same requisition appearing again after a gap | [Agent data plane](/features/agent-data-plane/) |
| `reobserved` | The same requisition still present, seen again | [Agent data plane](/features/agent-data-plane/) |
