---
title: Pipeline
parent: Concepts
layout: default
nav_order: 3
page_type: reference
verified_on: 2026-08-02
owner: mykola
description: The ordered stages every lead moves through, from signal to export, each owned by the page that documents it.
---

# Pipeline

Every lead moves through the same ordered stages. Each stage is owned by the feature page that
documents doing that step — a page carrying that stage's `stage:` key names it and links to the
stage before and after it.

```mermaid
graph LR
{% for stage in site.data.pipeline %}  {{ stage.key }}["{{ stage.name }}"]
{% endfor %}{% for stage in site.data.pipeline %}{% if stage.prerequisite %}  {{ stage.prerequisite }} --> {{ stage.key }}
{% endif %}{% endfor %}```

| Stage | Owning page |
|---|---|
{% for stage in site.data.pipeline %}| {{ stage.name }} | [{{ stage.owning_page }}]({{ stage.owning_page }}) |
{% endfor %}
