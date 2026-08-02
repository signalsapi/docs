---
title: Integration stopped receiving leads
parent: Troubleshooting
layout: default
nav_order: 7
page_type: symptom
search_aliases:
  - integration stopped
  - crm not receiving leads
  - webhook stopped working
  - leads not exporting
  - destination not receiving leads
description: "The two things that actually stop delivery to an integration: manual approval and credentials."
---

# Integration stopped receiving leads

## What you are seeing

Leads are matching and unlocking in SignalsAPI, but nothing new is showing up in your CRM,
outreach tool, or webhook destination.

## Most likely cause

**Manual Approval is enabled** on the search feeding this destination, and leads are sitting
unapproved. When Manual Approval is on, a lead only uploads to the integration after you open it
and click **Approve** — it is never uploaded automatically. See
[Integrations](/features/integrations/#approval-and-upload).

## Check this first

Open the search's settings and check whether **Manual Approval** is enabled. If it is, open your
leads and check their status: a lead reads something other than "Uploaded" until you open it and
click **Approve**.

## Other causes

- **The destination's credentials have expired or been revoked.** Every integration (Apollo,
  Snov.io, Bullhorn, and the rest) authenticates with a credential you obtained from that
  destination — if it's rotated or revoked there, delivery stops silently on this side too.
  Re-open **Settings → Integrations → your destination** and re-enter current credentials. See
  [Integrations](/features/integrations/).
- **The search's Destination field points somewhere else, or was never set.** See
  [Integrations](/features/integrations/#setting-up).

## Still stuck

Check [Is it working?](/is-it-working/) or email
[mykola@signalsapi.com](mailto:mykola@signalsapi.com) with which integration and search are
affected.
