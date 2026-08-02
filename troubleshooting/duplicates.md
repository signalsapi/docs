---
title: Duplicate companies
parent: Troubleshooting
layout: default
nav_order: 4
page_type: symptom
search_aliases:
  - duplicate companies
  - same company twice
  - duplicate leads
  - company added twice
  - duplicates setting
description: The Duplicates setting, its two independent controls, and their default values, stated as text.
---

# Duplicate companies

## What you are seeing

The same company appears more than once — either twice in one project, or again in a different
project you'd already added it to.

## Most likely cause

This is expected behavior, controlled by the **Duplicates** setting on the project, not a bug: by
default it allows a company to be matched again. See [Remove duplicate signals](/features/remove-duplicate-signals/).

## Check this first

Open the project's **Duplicates** setting and check both of its independent controls:

| Control | Question it answers | Default |
|---|---|---|
| **Within this list** | If a company has already been added to this list, can it be added again? | After 1 month |
| **Among all lists** | If a company has already been added to another list, can it be added to this one? | Yes |

## Other causes

- **Two real, separate job postings.** Some companies post the same job multiple times in
  different regions — this looks like a duplicate but is actually two distinct signals. See
  [Remove duplicate signals](/features/remove-duplicate-signals/).

## Still stuck

Check [Is it working?](/is-it-working/) or contact
[Support](/support/) with the project's Duplicates settings.
