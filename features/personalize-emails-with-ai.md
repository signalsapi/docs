---
title: Personalize emails with AI
parent: Features
layout: default
verified_on: 2026-08-03
owner: mykola
redirect_from: "/features/personalize-emails-with-ai.html"
nav_order: 11
page_type: feature
description: Use AI to clean up or transform raw signal data before dropping it into an email template.
---

# Personalize emails with AI

Use AI to clean, transform or summarize signals and use results in your emails.

## Example: Clean up job title

Using job title to personalize and customize emails sent to leads seems to be a great idea, but with an email template like this:

Email template
```text
I saw you are looking for a {job_title} and decided to reach out.
```

Inserting raw job title without any preprocessing leads to an unusable email text:

Without preprocessing
```text
I saw you are looking for a Python developer (£### - £### per annum) Permanent, full time. and decided to reach out.
```

Use AI to clean up the title to get better result:

AI Prompt
```text
This company is looking for {job_title}. Remove any location-specific details, company-specific jargon, or other non-essential elements from the job title. Use only words that capture the core essence of the position. Answer with exactly one sentence, not more than 10 words, mention the lowercase job title, start with: I saw you are looking for JOB_TITLE and decided to reach out.
```

Then modify your email template to include the AI-processed variable instead of the raw job title:

Email template
```text
{ai_field_1}
```

In this example, I do not use "I saw you are looking for" and "decided to reach out" because it is already part of the AI prompt, so the result will include these words.

Result
```text
I saw you are looking for a Python developer and decided to reach out.
```

## Setting up an email campaign with Snov.io using AI-generated values

Open a [project](https://app.signalsapi.com/leadlists/), add new or edit an existing one. In the "Enrichment" part of the form, add the prompt.

Add the custom fields to your CRM or outreach tool, e.g. for [Snovio](https://snov.io/):

1.  Open the prospect list [https://app.snov.io/prospects/](https://app.snov.io/prospects/), click the
    **···** menu on the prospect list toolbar, then **Manage custom fields and data tabs**.
2.  In the **Custom fields and data tabs** panel, add custom fields with any names, for example
    (as plain **Text** fields):

    | Field name | Type |
    |---|---|
    | `ai_field_1` | Text |
    | `ai_field_2` | Text |
    | `ai_field_3` | Text |
    | `ai_field_person` | Text |
3.  Insert them into your email text from Snov.io's own field picker — they appear as inline chips
    named after the field, e.g. one chip for `ai_field_person` followed by the words "I would like
    to" and a chip for `ai_field_1`.

## Need help writing a prompt?

Contact [Support](/support/) and describe your case.
