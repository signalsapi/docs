---
title: Filter leads with AI
parent: Features
layout: default
verified_on: 2026-08-03
owner: mykola
redirect_from: "/features/filter-leads-with-ai.html"
nav_order: 10
stage: filtering
page_type: feature
description: Use AI to filter leads against your ICP beyond what keyword and structured filters can catch.
---

# Filter leads with AI

Use AI to analyse and answer questions about the signal, the company, and decision-makers, then filter out wrong ones using stop-words.

## Example: Filter out staffing and recruiting agencies

Regular filter is usually not enough to filter out staffing and recruiting agencies, as not all of them identify themselves as belonging to "staffing & recruiting" industry.

AI Prompt
```text
Review the job description to determine if the company '{company_name}' hiring for itself or for a client. If the job description uses phrases like 'our client', 'we are partnering with a company', 'we are working with a company', or describes a company with an industry that is clearly not staffing, recruiting, or outsourcing, answer 'CLIENT'. If the job description is hiring for the company itself, answer 'SELF'. Answer with one word only and nothing else. Job Description Input: {job_description}
```

Stop-words
```text
client
```

Does not fit your case? Let me help: [Support](/support/)

## Getting started

Open [Lead Lists](https://app.signalsapi.com/leadlists/), add new or edit an existing one. In the "Enrichment" part of the form, add the prompt and stop-words.

Use the following variables in the prompt: [AI variables](../ai-variables/)

Find AI generated fields in each lead, on the lead's own detail page, under **AI generated**:

| Field | Example content |
|---|---|
| FIELD 1 | I saw you are looking for finance assistant and decided to reach out. |
| FIELD 2 | - Strong numeracy skills and Excel proficiency - Excellent attention to detail and accuracy - Effective communication and relationship-building skills |
| FIELD 3 | Self |

You can fine-tune your prompts by running them in [ChatGPT](https://chatgpt.com/?model=text-davinci-002-render-sha) to see the results. Replace {variables} in your prompts with actual job titles and descriptions.

## Need help writing a prompt?

Contact [Support](/support/) and describe your case.

{% include recent-changes.html %}
