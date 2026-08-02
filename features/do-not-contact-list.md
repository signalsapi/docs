---
title: Do-Not-Contact list
parent: Features
layout: default
verified_on: 2024-10-22
owner: mykola
redirect_from: "/features/do-not-contact-list.html"
nav_order: 14
page_type: feature
description: Block companies by domain or people by email so they're never matched or contacted again.
---

# Do-Not-Contact list

Make sure you do not contact companies or people you do not want to

## Getting started

Set it up in [Leads -> DNC](https://app.signalsapi.com/dnc/)

<div align="left">

<figure><img src="/features/do-not-contact-list.png" alt="" width="375"><figcaption></figcaption></figure>

</div>

## Filtering out domains

Put domain names of companies that should not be matched into "Domains" field of the Do-Not-Contact list.

It filters out all companies that have websites with these domains or ending with these domains. Do not put "www", "mail" or any other third-level prefixes:

* If you put `example.com` there, it will filter out both `http://example.com` and `http://www.example.com`
* If you put `www.example.com` there, it will filter out only `http://www.example.com`, but if company specifies its website as `http://example.com` it will not be filtered out

## Filtering out individual emails

To filter out someone without filtering out the whole company, put their email in "Emails" field of the Do-Not-Contact list.
