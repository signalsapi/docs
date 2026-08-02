---
title: API access
parent: Features
layout: default
verified_on: 2026-08-02
owner: mykola
redirect_from: "/features/api-access.html"
nav_order: 16
stage: export_and_integration
page_type: feature
description: Pull your own projects and leads out of SignalsAPI as JSON or CSV over a read-only REST API.
---

# API access

Pull your projects and leads out of SignalsAPI programmatically — the same data
you see in the app, available as JSON or CSV over a small REST API. Build it into
a script, a scheduled sync, or your own dashboard.

The API is **read-only** and returns exactly what you can already see and download
in the app: your own projects, their leads, and a full per‑project export that is
identical to the project's **Download CSV** button.

Building an AI agent, or want the underlying hiring panel rather than your own leads?
That is a separate machine-facing surface — see the
**[Agent data plane](../agent-data-plane/)**.

## Base URL

```text
https://api.signalsapi.com
```

## Authentication

Every request uses your personal API key as a Bearer token:

```text
Authorization: Bearer YOUR_API_KEY
```

Find your key in the app under **Settings → API Key** (you can regenerate it there
at any time — regenerating invalidates the old key). Every request is scoped to
your own account: you can only ever see your own projects and leads.

| Situation | Response |
|-----------|----------|
| Missing or invalid key | `403` |
| Expired or deactivated key | `403` |
| A project that isn't yours, or doesn't exist | `404` |
| An unsupported `format` value | `422` |

---

## List your projects

```text
GET /projects/
```

Returns all of your projects, newest first, each with a `usable_lead_count`
(the number of leads in that project that are ready to use).

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
  https://api.signalsapi.com/projects/
```

```json
{
  "projects": [
    {
      "id": 654,
      "name": "Customer Success",
      "export_name": null,
      "created_at": "2026-05-12T09:31:00",
      "updated_at": "2026-06-28T14:02:11",
      "usable_lead_count": 85
    }
  ],
  "total": 1
}
```

---

## Browse a project's leads

```text
GET /projects/{project_id}/leads
```

Page through a project's usable leads as structured JSON. Each lead carries its
nested `person` and `company`.

| Query parameter | Default | Notes |
|-----------------|---------|-------|
| `limit` | `50` | Page size, `1`–`500` |
| `offset` | `0` | Number of leads to skip |
| `unlocked_only` | `false` | Return only unlocked leads |

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
  "https://api.signalsapi.com/projects/654/leads?limit=2&offset=0"
```

```json
{
  "leads": [
    {
      "id": 90217,
      "project_id": 654,
      "created_at": "2026-06-20T08:14:00",
      "updated_at": "2026-06-20T08:14:00",
      "unlocked_at": null,
      "email": null,
      "email_status": "verified",
      "is_usable": true,
      "person": {
        "id": null,
        "first_name": "Matteo",
        "last_name": "Attems-Thonet",
        "name": "Matteo Attems-Thonet",
        "title": "Head of Customer Success",
        "headline": null,
        "linkedin_url": "https://www.linkedin.com/in/…"
      },
      "company": {
        "id": 4412,
        "name": "zollsoft GmbH",
        "domain": "zollsoft.de",
        "industry": "Software",
        "country": "DE",
        "headcount": 180
      }
    }
  ],
  "total": 85,
  "limit": 2,
  "offset": 0
}
```

`total` is the full count of usable leads in the project (not just the current
page) — use it to drive pagination. To pull every lead at once, use the export
endpoint below instead of paging.

---

## Export a whole project

```text
GET /projects/{project_id}/leads/export?format=json|csv
```

Streams **all** usable leads of a project in one response — no page limit. The
CSV is byte‑for‑byte the same file you get from the project's **Download CSV**
button in the app, so any importer mapping you already have keeps working.

| Query parameter | Default | Values |
|-----------------|---------|--------|
| `format` | `json` | `json`, `csv` |

```bash
# CSV, streamed straight to a file
curl -H "Authorization: Bearer YOUR_API_KEY" \
  "https://api.signalsapi.com/projects/654/leads/export?format=csv" \
  -o leads.csv

# JSON array of rich rows
curl -H "Authorization: Bearer YOUR_API_KEY" \
  "https://api.signalsapi.com/projects/654/leads/export?format=json"
```

The CSV columns are:

```text
website,decision_maker_linkedin_url,decision_maker_email,decision_maker_phone,signal_job_title
```

The JSON export returns the same rows with the full set of person, company, and
signal fields. A project with no usable leads exports cleanly — a header‑only CSV
or an empty `[]` — rather than an error.

The export is streamed, so even very large projects download in constant memory
on both ends. It is read‑only and never consumes credits.

---

## Notes & limits

- **Usable leads only.** All three endpoints return the same usable‑lead set you
  see in the app; the export matches the web CSV download exactly.
- **Read‑only.** Nothing here unlocks leads, runs enrichment, or spends credits.
- **Your data only.** Requests are always scoped to your account; another user's
  project id returns `404`.
- **Rate limiting** on the export endpoint is not yet enforced — be reasonable
  with very frequent full pulls.

See [Limits](/limits/) for every pagination default and rate limit stated across the API in one
place.
