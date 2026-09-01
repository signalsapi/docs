---
title: Duplicate companies
parent: Troubleshooting
layout: default
verified_on: 2026-09-01
owner: mykola
nav_order: 4
page_type: symptom
search_aliases:
  - duplicate companies
  - same company twice
  - duplicate leads
  - company added twice
  - signals per company per day
description: Why one company appears more than once in a project, and why the same company in two projects is never a fault.
---

# Duplicate companies

## What you are seeing

The same company appears more than once — either twice in one project, or again in a different
project you had already added it to.

## Most likely cause

Which of those two you are looking at decides the answer, and they are unrelated.

**Twice in one project.** The project's **Signals per company per day** holds a number, so the
company is allowed to contribute that many hiring signals in a day. Left empty — the default — a
project takes each company once and never again, so this does not happen at all. Projects in
**Test mode** start at 3 rather than empty, so repeats there are expected without anyone changing
a field. See [Remove duplicate signals](/features/remove-duplicate-signals/).

**Again in a different project.** Expected, and not a setting. Each project decides on its own
which companies it holds, and adding a company to one project has never kept it out of another.

## Check this first

Open the project and look at **Signals per company per day**, under Basic filters:

| What you find | What it means |
|---|---|
| Empty | Each company is taken once and never again. A repeat inside this project is not coming from here. |
| A number N | Up to N signals from the same company per day. Clear it to go back to once, ever. |

If the field is empty and you are still seeing one company twice in one project, that is worth
reporting.

## Other causes

- **Two real, separate job postings.** Some companies post the same job several times in
  different regions. These are genuinely distinct signals rather than copies — but you will only
  ever see one of them while the field is empty, so this explains a repeat only on a project that
  allows them. See [Remove duplicate signals](/features/remove-duplicate-signals/).

## Still stuck

Check [Is it working?](/faq/#is-it-working) or contact
[Support](/support/) with the project's **Signals per company per day** value.
