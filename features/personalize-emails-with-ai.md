---
title: Personalize emails with AI
parent: Features
layout: home
nav_order: 5
---

# Personalize emails with AI

Use AI to clean, transform or summarize signals and use results in your emails.

## Example: Clean up job title

Using job title to personalize and customize emails sent to leads seems to be a great idea, but with an email template like this:

Email template
```
I saw you are looking for a {job_title} and decided to reach out.
```

Inserting raw job title without any preprocessing leads to an unusable email text:

Without preprocessing
```
I saw you are looking for a Python developer (£### - £### per annum) Permanent, full time. and decided to reach out.
```

Use AI to clean up the title to get better result:

AI Prompt
```
This company is looking for {job_title}. Remove any location-specific details, company-specific jargon, or other non-essential elements from the job title. Use only words that capture the core essence of the position. Answer with exactly one sentence, not more than 10 words, mention the lowercase job title, start with: I saw you are looking for JOB_TITLE and decided to reach out.
```

Then modify your email template to include the AI-processed variable instead of the raw job title:

Email template
```
{ai_field_1}
```

In this example, I do not use "I saw you are looking for" and "decided to reach out" because it is already part of the AI prompt, so the result will include these words.

Result
```
I saw you are looking for a Python developer and decided to reach out.
```

## Getting started

Open [Lead Lists](https://app.signalsapi.com/leadlists/), add new or edit an existing one. In the "Enrichment" part of the form, add the prompt.&#x20;

Use the following variables in the prompt: [ai-variables.md](ai-variables.md "mention")

Add the custom fields to your CRM or outreach tool, e.g. for Snovio:

1.  Open the prospect list [https://app.snov.io/prospects/](https://app.snov.io/prospects/), click ... -> Manage custom fields and data tabs

    <div align="left">

    <figure><img src="/images/personalize-emails-with-ai-1.png" alt="" width="563"><figcaption></figcaption></figure>

    </div>
2.  Add fields **ai\_field\_1**, **ai\_field\_1**, **ai\_field\_3**, and **ai\_field\_person** to the list

    <div align="left">

    <figure><img src="/images/personalize-emails-with-ai-2.png" alt="" width="375"><figcaption></figcaption></figure>

    </div>
3.  Use them in email text

    <div align="left">

    <figure><img src="/images/personalize-emails-with-ai-3.png" alt="" width="200"><figcaption></figcaption></figure>

    </div>

## Need help writing a prompt?

Contact me at [mykola@signalsapi.com](mailto:mykola@signalsapi.com) and describe your case.
