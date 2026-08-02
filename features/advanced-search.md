---
title: Advanced search
parent: Features
layout: default
redirect_from: "/features/advanced-search.html"
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

```text
project manager
construction site manager
senior project lead
```

Each line is a separate search term. A signal matches if any of the terms appear in the title or description.

### Semantic search

AI-powered search that finds signals with similar meaning, not just exact keywords. Enter a natural language description of the role you're looking for.

```text
project manager, delivery lead
```

This will also find signals with titles like "Program Director", "PMO Lead", "Delivery Manager", "Construction Coordinator" -- roles that are semantically similar but use different words.

Use semantic search when keyword search returns too few results, or when the same role goes by many different names.

## Filtering signals

Every filter below is optional. Required words use OR logic *within* a field (match any one of
them) and AND logic *across* fields (e.g. a title requirement and a description requirement must
both hold), so you can stack them — e.g. require `qa` in the title **and** `remote`/`home`/`hybrid`
in the description.

### Job title and description requirements

| Filter | Options | Default |
|---|---|---|
{% assign section_filters = "Job title required words,Job description required words,Stop words" | split: "," %}{% for f in site.data.filters.items %}{% if section_filters contains f.label %}| **{{ f.label }}** | {{ f.options }} | {{ f.default }} |
{% endif %}{% endfor %}

### Skills filter

Filter by skills mentioned in the job posting.

| Filter | Options | Default |
|---|---|---|
{% assign section_filters = "Required skills,Exclude skills" | split: "," %}{% for f in site.data.filters.items %}{% if section_filters contains f.label %}| **{{ f.label }}** | {{ f.options }} | {{ f.default }} |
{% endif %}{% endfor %}

### Job families

Filter by structured job classification. This catches relevant signals regardless of how the title is worded.

| Filter | Options | Default |
|---|---|---|
{% assign section_filters = "Job families" | split: "," %}{% for f in site.data.filters.items %}{% if section_filters contains f.label %}| **{{ f.label }}** | {{ f.options }} | {{ f.default }} |
{% endif %}{% endfor %}

### Location filters

| Filter | Options | Default |
|---|---|---|
{% assign section_filters = "Search location,Location patterns" | split: "," %}{% for f in site.data.filters.items %}{% if section_filters contains f.label %}| **{{ f.label }}** | {{ f.options }} | {{ f.default }} |
{% endif %}{% endfor %}

### Date filter

| Filter | Options | Default |
|---|---|---|
{% assign section_filters = "Maximum age of job posting" | split: "," %}{% for f in site.data.filters.items %}{% if section_filters contains f.label %}| **{{ f.label }}** | {{ f.options }} | {{ f.default }} |
{% endif %}{% endfor %}

## Filtering companies

### Exclude staffing agencies

More reliable than manually listing stop words like "staffing" or "recruiting".

| Filter | Options | Default |
|---|---|---|
{% assign section_filters = "Exclude staffing agencies" | split: "," %}{% for f in site.data.filters.items %}{% if section_filters contains f.label %}| **{{ f.label }}** | {{ f.options }} | {{ f.default }} |
{% endif %}{% endfor %}

### Company attributes

| Filter | Options | Default |
|---|---|---|
{% assign section_filters = "Headquarters location,Industries,Company size,Company required words / stop words" | split: "," %}{% for f in site.data.filters.items %}{% if section_filters contains f.label %}| **{{ f.label }}** | {{ f.options }} | {{ f.default }} |
{% endif %}{% endfor %}

## Signal quality filters

### Hard to fill

Companies actively struggling to fill the position are more receptive to outreach.

| Filter | Options | Default |
|---|---|---|
{% assign section_filters = "Hard to fill" | split: "," %}{% for f in site.data.filters.items %}{% if section_filters contains f.label %}| **{{ f.label }}** | {{ f.options }} | {{ f.default }} |
{% endif %}{% endfor %}

### Hiring surge

Companies in a growth phase are more likely to engage.

| Filter | Options | Default |
|---|---|---|
{% assign section_filters = "Hiring surge" | split: "," %}{% for f in site.data.filters.items %}{% if section_filters contains f.label %}| **{{ f.label }}** | {{ f.options }} | {{ f.default }} |
{% endif %}{% endfor %}

Every filter above lives on the same screen — see its click path in
[Create a search](/create-a-search/) for the full step-by-step walkthrough.

## Tips for getting more results

1. **Start with semantic search** -- it finds signals that keyword search misses
2. **Combine keyword + semantic** -- use keywords for precision and semantic for breadth
3. **Add description required words** -- when titles are noisy, require a keyword in the description (e.g. `remote`/`home`/`hybrid` for remote-friendly roles) to cut out signals that don't actually match
4. **Use "Exclude staffing agencies"** instead of manually listing staffing stop words
5. **Try "Hard to fill"** to focus on companies most likely to respond
6. **Widen your location** -- add location patterns for specific cities instead of limiting to a single country
