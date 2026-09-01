---
title: Remove duplicate signals
parent: Features
layout: default
verified_on: 2026-09-01
owner: mykola
redirect_from: "/features/remove-duplicate-signals.html"
nav_order: 2
page_type: feature
description: How many hiring signals one company can contribute to a project, and how to let a company appear more than once.
---

# Remove duplicate signals

Some companies post the same job several times in different regions — the same employer and job
title recurring across locations, e.g.:

| Company | Job title | Location |
|---|---|---|
| DataAnnotation | Frontend Developer | United States |
| DataAnnotation | Software Developer | Fremont, CA |
| DataAnnotation | Frontend Developer | Mountain View, CA |
| DataAnnotation | Web Developer | Salt Lake City Metropolitan Area |
| DataAnnotation | Software Developer | Long Beach, CA |

By default a project takes **one** of those five and never that company again. The other four are
dropped as duplicates of a company the project already holds. That is usually what you want: the
thing you act on is a company to approach, and a second posting at the same employer is the same
approach twice.

## When you want the repeats

One control changes it, on the project itself:

{% include controls-table.html screen="Basic filters" %}

Leave it empty and the rule above applies for the life of the project. Set it to a number and the
project will take up to that many signals from the same company per day.

Raise it when a narrow persona matches many postings across few employers. A project like that can
run out of companies long before it runs out of postings, and every extra posting it finds is
discarded — so it stalls with fewer results than the market actually offered it. Projects in
**Test mode**, which stop at ten deliverable leads, start at 3 for exactly this reason.

Each posting admitted this way is a separate signal in the project and counts toward **Max
signals**, so a project with both set will reach its signal limit sooner.

## Not the same as decision-makers per company

This control counts **signals** — job postings from one company. **Max decision-makers per
company**, on the persona, counts **people** found at each company. They are independent: one
company contributing three signals can still return one person, and one signal can return three
people.

## Across projects

There is nothing to configure. A company added to one project has never been withheld from another
— every project decides on its own, and two projects can hold the same company at the same time.

{% include recent-changes.html %}
