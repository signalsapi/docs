---
title: Developer quickstart
parent: Quick start
layout: default
nav_order: 2
page_type: task
description: The shortest path from an API key to exported rows, using the REST reference's own examples.
---

# Developer quickstart

## Before you start

You need a SignalsAPI account and an API key. Find or generate your key in the app under
**Settings → API Key** — see [API access](/features/api-access/) for the full reference this
quickstart pulls from.

## Steps

1. **Export your key.**

   ```bash
   export SIGNALSAPI_KEY="YOUR_API_KEY"
   ```

2. **List your projects** to find a `project_id` and see how many leads are usable.

   ```bash
   curl -H "Authorization: Bearer $SIGNALSAPI_KEY" \
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

3. **Export that project's leads** — every usable lead, in one response, no paging.

   ```bash
   curl -H "Authorization: Bearer $SIGNALSAPI_KEY" \
     "https://api.signalsapi.com/projects/654/leads/export?format=csv" \
     -o leads.csv
   ```

   The CSV columns are the same ones documented on [API access](/features/api-access/):

   ```text
   website,decision_maker_linkedin_url,decision_maker_email,decision_maker_phone,signal_job_title
   ```

## Check it worked

`leads.csv` should have a header row matching the columns above, plus one data row per usable
lead — `usable_lead_count` from step 2 tells you how many rows to expect. A project with no
usable leads still exports cleanly: a header-only CSV rather than an error.

## If it did not work

A `403` or `404` means authentication or the resource id is the problem, not your export logic —
see [My API request returns an authorization error](/troubleshooting/api-auth/), which maps every
status code to its cause. If the response looks right but the row count doesn't match, check
[Is it working?](/is-it-working/) for a platform-wide issue, or contact [Support](/support/).
