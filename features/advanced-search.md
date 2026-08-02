---
title: Advanced search
parent: Features
layout: default
nav_order: 3
stage: signal_discovery
page_type: feature
description: Semantic search, description search, skills filters, and other ways to narrow which signals match.
---

# Advanced search

SignalsAPI offers multiple ways to find relevant hiring signals. Combine them to cast a wider net while keeping results precise.

## Search methods

### Keyword search (Search for)

The default search method. Enter job titles or keywords and the system will match them against job posting titles and descriptions using full-text search.

```
project manager
construction site manager
senior project lead
```

Each line is a separate search term. A signal matches if any of the terms appear in the title or description.

### Semantic search

AI-powered search that finds signals with similar meaning, not just exact keywords. Enter a natural language description of the role you're looking for.

```
project manager, delivery lead
```

This will also find signals with titles like "Program Director", "PMO Lead", "Delivery Manager", "Construction Coordinator" -- roles that are semantically similar but use different words.

Use semantic search when keyword search returns too few results, or when the same role goes by many different names.

## Filtering signals

### Job title and description requirements

* **Job title required words** -- the signal title must contain at least one of these words. Narrows results to the titles you actually want (e.g. `qa`, `quality assurance`).
* **Job description required words** -- the signal description must contain at least one of these words. A signal is kept only if its description matches. Great for **remote-friendly** filtering -- list `remote`, `home`, `hybrid` to keep only roles whose description mentions remote work.
* **Stop words** -- signals whose title **or** description contains any of these words are excluded (e.g. `our client`, `on behalf`, `intern`).

Required words use OR logic *within* a field (match any one of them) and AND logic *across* fields (title requirement and description requirement must both hold), so you can stack them -- e.g. require `qa` in the title **and** `remote`/`home`/`hybrid` in the description.

### Skills filter

Filter by skills mentioned in the job posting.

* **Required skills** -- signal must mention ALL of these skills (AND logic). Example: `PMP, Agile`
* **Exclude skills** -- signals mentioning ANY of these skills are excluded (OR logic). Example: `SAP`

### Job families

Filter by structured job classification. The system categorizes each signal into a job family (e.g., "Engineering", "Project Management", "Sales"). This catches relevant signals regardless of how the title is worded.

### Location filters

* **Search location** -- country where the job is posted (e.g., United Kingdom)
* **Location patterns** -- match specific cities or regions within a country (e.g., `London`, `Manchester`, `Birmingham`). Useful when you need results from specific areas, not the entire country.

### Date filter

**Maximum age of job posting** controls how recent the signal must be. Set to 7 to only see signals from the last week, or 30 for the last month.

## Filtering companies

### Exclude staffing agencies

A built-in filter that automatically removes signals posted by staffing, recruiting, and outsourcing agencies. More reliable than manually listing stop words like "staffing" or "recruiting".

### Company attributes

* **Headquarters location** -- filter by where the company is based
* **Industries** -- include or exclude specific industries
* **Company size** -- minimum and maximum number of employees
* **Required words / Stop words** -- match or exclude based on company name, headline, description, and specialties

## Signal quality filters

### Hard to fill

Only shows roles that have been open for 30+ days or reposted 3+ times. These companies are actively struggling to fill the position, making them more receptive to outreach.

### Hiring surge

Only shows signals from companies with 5+ new roles in the last 30 days at 1.5x their previous hiring rate. These companies are in a growth phase and are more likely to engage.

## Tips for getting more results

1. **Start with semantic search** -- it finds signals that keyword search misses
2. **Combine keyword + semantic** -- use keywords for precision and semantic for breadth
3. **Add description required words** -- when titles are noisy, require a keyword in the description (e.g. `remote`/`home`/`hybrid` for remote-friendly roles) to cut out signals that don't actually match
4. **Use "Exclude staffing agencies"** instead of manually listing staffing stop words
5. **Try "Hard to fill"** to focus on companies most likely to respond
6. **Widen your location** -- add location patterns for specific cities instead of limiting to a single country
