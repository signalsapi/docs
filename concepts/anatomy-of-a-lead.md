---
title: Anatomy of a lead
parent: Concepts
layout: default
page_type: concept
nav_order: 2
description: Every field on a lead row, and which of the three sources it comes from.
---

# Anatomy of a lead

## What it is

A lead is one row in a [project](/features/api-access/)'s export — the join of a single hiring
signal, one person at the hiring company, and that company's own record. Every field on the row
traces back to exactly one of three sources: the job posting itself, the people-data provider
SignalsAPI queried for that person and company, or a value SignalsAPI derived after the fact.

| Field | What it is | Source |
|---|---|---|
| `email` | Verified email address | People-data provider |
| `email_status` | The result of SignalsAPI's email verification step | Derived value |
| `is_usable` | Whether this lead counts toward the project's usable-lead total | Derived value |
| `first_name` | First name | People-data provider |
| `last_name` | Last name | People-data provider |
| `title` | Job title | People-data provider |
| `headline` | LinkedIn headline | People-data provider |
| `linkedin_url` | LinkedIn profile URL | People-data provider |
| `company_name` | Company name | People-data provider |
| `company_domain` | Company domain | People-data provider |
| `company_website` | Company website | People-data provider |
| `company_industry` | Industry | People-data provider |
| `company_headcount` | Number of employees | People-data provider |
| `company_headquarters` | HQ location | People-data provider |
| `company_description` | Company description | People-data provider |
| `company_linkedin` | Company LinkedIn URL | People-data provider |
| `signal_title` | Hiring signal job title | The job posting |
| `signal_url` | Hiring signal URL | The job posting |
| `signal_location` | Signal location | The job posting |
| `signal_country` | Signal country | The job posting |
| `signal_description` | Full job description | The job posting |
| `ai_field_1` - `ai_field_5` | AI-generated custom fields | Derived value |

## Why it matters

The source tells you how much to trust a field and whether it's worth re-checking. A job-posting
field is only as fresh as the posting itself. A people-data provider field carries whatever
accuracy limits that provider has. A derived field — `email_status`, `is_usable`, the `ai_field_*`
set — is something SignalsAPI computed from the other two, not something you can look up
independently.

## How it fits the pipeline

The job posting is found first, which is where every `signal_*` field comes from. SignalsAPI then
looks up the hiring company and a person there through a people-data provider, which is where the
contact and company fields come from. Only after both of those exist does SignalsAPI derive the
row's status fields and decide whether it's usable. See [How it works](/how-it-works/) for the
full walkthrough.

## Related

- [Glossary](/concepts/glossary/)
- [API access](/features/api-access/)
- [Integrations](/features/integrations/)
