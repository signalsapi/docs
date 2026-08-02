---
title: AI filter rejected everything
parent: Troubleshooting
layout: default
nav_order: 5
page_type: symptom
search_aliases:
  - AI filter rejected everything
  - AI filter too strict
  - AI rejecting good leads
  - enrichment prompt rejects all leads
  - ai_field empty
description: Which AI template variables come back empty depending on your connected people-data provider.
---

# AI filter rejected everything

## What you are seeing

You added an AI prompt to filter or score leads, and now every lead is being rejected — even ones
that clearly match your criteria.

## Most likely cause

Your prompt references a variable that's empty for your connected provider, so the AI is
evaluating blank text instead of real data. The most common case: a prompt using `{phone}` or
`{phone_status}` when your connected provider isn't LeadMagic — every other provider leaves those
empty. See [AI variables](/features/ai-variables/) and
[Compare people-data providers](/features/compare-people-data-providers/).

## Check this first

Open the project's Enrichment prompt and check every placeholder it references against what your
connected provider actually returns:

| Variable | Empty unless... |
|---|---|
| `{phone}`, `{phone_status}` | Your connected provider is LeadMagic |
| `{linkedin_url}` | Rarely empty — occasionally missing with Snov.io |

See [AI variables](/features/ai-variables/) for the full variable list, and
[Compare people-data providers](/features/compare-people-data-providers/) for what each provider
returns.

## Other causes

- **The prompt's instructions are too strict** for the job descriptions you're matching against —
  see the [Filter leads with AI](/features/filter-leads-with-ai/) example of testing a prompt in
  ChatGPT before relying on it.
- **The AI is answering with more than the expected single word or format**, and your stop-words
  match against that unexpected text. See [Filter leads with AI](/features/filter-leads-with-ai/).

## Still stuck

Check [Is it working?](/is-it-working/) or email
[mykola@signalsapi.com](mailto:mykola@signalsapi.com) with your prompt and connected provider.
