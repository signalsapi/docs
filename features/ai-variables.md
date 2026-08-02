---
title: AI variables
parent: Features
layout: default
nav_order: 12
page_type: feature
description: The company, signal, and person variables you can insert into AI prompts and email templates.
---

# AI variables

Include a variable in curly braces like this `{company_name}`.

## Company variables

Always populated from the hiring company's own record — not affected by which people-data
provider you connect.

| Variable | Meaning |
|---|---|
{% for v in site.data.variables.items %}{% if v.kind == "company" %}| `{{ v.name }}` | {{ v.meaning }} |
{% endif %}{% endfor %}

## Signal variables

Always populated from the hiring signal itself.

| Variable | Meaning |
|---|---|
{% for v in site.data.variables.items %}{% if v.kind == "signal" %}| `{{ v.name }}` | {{ v.meaning }} |
{% endif %}{% endfor %}

## Person variables

Availability depends on which [people-data provider](../bring-your-own-people-provider/) you
connect — see [Compare people-data providers](../compare-people-data-providers/) for the full
comparison.

| Variable | Meaning | Populated by |
|---|---|---|
{% for v in site.data.variables.items %}{% if v.kind == "person" %}| `{{ v.name }}` | {{ v.meaning }} | {{ v.providers | join: ", " }} |
{% endif %}{% endfor %}
