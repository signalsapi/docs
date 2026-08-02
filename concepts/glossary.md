---
title: Glossary
layout: default
nav_order: 10
description: Every SignalsAPI product term defined once, in one place, in alphabetical order.
---

# Glossary

One definition per term. If a page uses a name you don't recognize, it's here — in alphabetical
order, each linking back to the page where it's actually used.

{% assign sorted_glossary = site.data.glossary | sort_natural: "term" %}
{% for entry in sorted_glossary %}
## {{ entry.term }} {#{{ entry.term | slugify }}}

{{ entry.definition }}

See it in context: [{{ entry.owning_page }}]({{ entry.owning_page }})
{% if entry.aliases %}

Also called: {% for alias in entry.aliases %}{{ alias.name }}{% unless forloop.last %}, {% endunless %}{% endfor %}.
{% endif %}
{% endfor %}
