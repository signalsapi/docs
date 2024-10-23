---
title: Filter leads with AI
parent: Features
layout: home
nav_order: 4
---

# Filter leads with AI

Use AI to analyse and answer questions about the signal, the company, and decision-makers, then filter out wrong ones using stop-words.

## Example: Filter out staffing and recruiting agencies

Regular filter is usually not enough to filter out staffing and recruiting agencies, as not all of them identify themselves as belonging to "staffing & recruiting" industry.

AI Prompt
```
Review the job description to determine if the company '{company_name}' hiring for itself or for a client. If the job description uses phrases like 'our client', 'we are partnering with a company', 'we are working with a company', or describes a company with an industry that is clearly not staffing, recruiting, or outsourcing, answer 'CLIENT'. If the job description is hiring for the company itself, answer 'SELF'. Answer with one word only and nothing else. Job Description Input: {job_description}
```

Stop-words
```
client
```

Does not fit your case? Let me help: [mykola@signalsapi.com](mailto:mykola@signalsapi.com)

## Getting started

Open [Lead Lists](https://app.signalsapi.com/leadlists/), add new or edit an existing one. In the "Enrichment" part of the form, add the prompt and stop-words.

Use the following variables in the prompt: [ai-variables.md](ai-variables.md "mention")

Find AI generated fields in each lead:

<div align="left">

<figure><img src="/features/filter-leads-with-ai.png" alt="" width="375"><figcaption></figcaption></figure>

</div>

You can fine-tune your prompts by running them in [ChatGPT](https://chatgpt.com/?model=text-davinci-002-render-sha) to see the results. Replace {variables} in your prompts with actual job titles and descriptions.

## Need help writing a prompt?

Contact me at [mykola@signalsapi.com](mailto:mykola@signalsapi.com) and describe your case.
