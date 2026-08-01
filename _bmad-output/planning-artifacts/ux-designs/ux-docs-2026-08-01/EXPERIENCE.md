---
title: 'SignalsAPI Docs — EXPERIENCE.md'
status: final
created: '2026-08-01'
updated: '2026-08-01'
project: docs
form_factor: 'Static documentation website. Server-rendered at build time, no client state, no auth, no forms.'
ui_system: 'just-the-docs 0.10.0 (exact-pinned). Visual identity: DESIGN.md.'
sources:
  - '_bmad-output/planning-artifacts/prds/prd-docs-2026-08-01/prd.md'
  - '_bmad-output/planning-artifacts/briefs/brief-docs-2026-08-01/brief.md'
  - '_bmad-output/planning-artifacts/briefs/brief-docs-2026-08-01/addendum.md'
  - '_bmad-output/project-context.md'
  - '_bmad-output/brainstorming/brainstorm-better-docs-2026-07-31/.memlog.md'
---

# EXPERIENCE.md — SignalsAPI Documentation Site

## Foundation

**Form factor.** One surface: a static website at `docs.signalsapi.com`, built by
Jekyll 4.3.4 and served from GitHub Pages via a custom Actions workflow. There is
no app to design. There is no session, no account, no state that survives a page
load, and nothing that POSTs.

**UI system.** just-the-docs 0.10.0, exact-pinned. It owns layout, responsive
behaviour, the sidebar, breadcrumbs, and the lunr search index at
`assets/js/search-data.json`. This document specifies only the **behavioural
delta** on top of it. Visual identity — colors, type, radii, shadows, the eight
permitted components — is DESIGN.md, and DESIGN.md is a freeze contract.

**The one architectural fact that shapes everything below:** just-the-docs
navigation is driven by **front matter only**. There is no nav data file. A page
declares `title`, `nav_order`, `parent`, `has_children`, `nav_exclude` — and the
sidebar assembles itself. `parent:` matches the **title** of another page, not a
directory. Nesting is therefore **independent of file location**.

That single fact is why this IA restructure ships **zero redirects**. Every page
that exists today keeps its URL. Every nesting change is a front-matter edit. New
sections are new files at new URLs. The URL surface is the site's only SEO asset,
and this plan does not spend it.

**The gate.** `bundle exec rake check` = `jekyll build` → `html-proofer` → `vale`
→ `ruby script/check.rb`. Every convention in this document is stated together
with the assertion that enforces it. A convention with no assertion is a
suggestion, and suggestions rot. That is what produced the current site.

## Information Architecture

### What is wrong now

Eleven pages sit at the root with `nav_order` values that are pure accretion:
`is-it-working.md` and `privacy-policy.md` both declare `nav_order: 6`, `5` is
unused, and elsewhere the values are float shims — `1.5`, `2.5`, `3.5`, `3.6`,
`3.7`, `11.1`–`11.3` — each one a past decision to insert a page without
renumbering. `features/index.md` is a 10-word landing page with `nav_order: 3`
and **no** `has_children: true`, so the twenty `features/*` pages render as
siblings of root pages rather than as its children. `request-new-feature.md` sits
at `nav_order: 0` — the literal first thing a reader sees. Legal and status pages
compete with content for nav slots.

### The tree

Eleven top-level entries. Integer `nav_order`, contiguous from 1, no gaps, no
floats, no duplicates — at every level.

| # | Title | File | Kind |
|---|---|---|---|
| 1 | Home | `index.md` | router |
| 2 | Quick start | `quick-start.md` | router, `has_children` |
| 3 | Concepts | `concepts/index.md` | router, `has_children` |
| 4 | Features | `features/index.md` | router, `has_children` |
| 5 | APIs | `apis/index.md` | router, `has_children` |
| 6 | Troubleshooting | `troubleshooting/index.md` | router, `has_children` |
| 7 | Pricing | `pricing.md` | reference |
| 8 | Support | `support.md` | reference |
| 9 | FAQ | `faq.md` | reference |
| 10 | What's new | `whats-new/index.md` | reference |
| 11 | Trust | `trust.md` | router, `has_children` |

**2 — Quick start** (`parent: Quick start`)

| # | Title | File |
|---|---|---|
| 1 | For operators | `quick-start/operator.md` |
| 2 | For developers | `quick-start/developer.md` |
| 3 | For AI agents | `quick-start/agent.md` |

`quick-start.md` itself is the shared five-minute path; the three children are
role-shaped forks off it. The deleted original is recoverable at `835852a^` and
is the starting text, not a blank page.

**3 — Concepts** (`parent: Concepts`)

| # | Title | File | Note |
|---|---|---|---|
| 1 | Anatomy of a lead | `concepts/anatomy-of-a-lead.md` | field-by-field walk of one real record |
| 2 | How it works | `how-it-works.md` | **existing file, unmoved.** Gains `parent: Concepts`. |
| 3 | Signals and the pipeline | `concepts/pipeline.md` | the `stage:` reference; source for the "you are here" strip |
| 4 | Glossary | `concepts/glossary.md` | rendered from `_data/glossary.yml` |

**4 — Features** (`parent: Features`) — the twenty existing `features/*.md` pages
minus the four promoted to APIs, minus `request-new-feature.md` which is
`nav_exclude`d to the footer. Fifteen children, renumbered 1–15 in the order a
reader would meet them, not alphabetically. `features/index.md` gains
`has_children: true` — the one-line fix for F9 — and becomes a real router
instead of ten words.

**5 — APIs** (`parent: APIs`) — memlog L118 and L284. `apis/index.md` is a **new**
router page. The four existing API pages are promoted **by front matter only**;
their files do not move and their URLs do not change.

| # | Title | File | Note |
|---|---|---|---|
| 1 | API access | `features/api-access.md` | unmoved, `parent: APIs` |
| 2 | Agent data plane | `features/agent-data-plane.md` | unmoved, `parent: APIs` |
| 3 | Agent data plane — REST | `features/agent-data-plane-api.md` | unmoved |
| 4 | Agent data plane — MCP | `features/agent-data-plane-mcp.md` | unmoved |
| 5 | Agent data plane — Clay | `features/agent-data-plane-clay.md` | unmoved |
| 6 | Limits | `limits.md` | new |

> **Decision, stated because it looks like a compromise and is not.** A file at
> `features/api-access.md` appearing under a top-level **APIs** heading is a URL
> that disagrees with the nav. The alternative — `git mv` into `apis/` — costs
> five `redirect_from` entries, five chances to typo one, and buys a cosmetic
> gain. The nav is what readers use; the URL is what search engines hold. Promote
> the nav, keep the URLs. If the files are ever moved, the move ships with
> `jekyll-redirect-from` entries in the same commit, per the scope boundary.

**6 — Troubleshooting** (`parent: Troubleshooting`) — symptom-named, memlog L72.
Titles are the sentence the reader would type, not the subsystem name.

| # | Title | File |
|---|---|---|
| 1 | My search returned no results | `troubleshooting/empty-results.md` |
| 2 | My results are the wrong companies | `troubleshooting/wrong-companies.md` |
| 3 | I'm not getting phone numbers | `troubleshooting/no-phone-numbers.md` |
| 4 | I'm seeing duplicate signals | `troubleshooting/duplicates.md` |
| 5 | My AI filter rejects everything | `troubleshooting/ai-filter-too-strict.md` |
| 6 | My API call returns 401 or 403 | `troubleshooting/api-auth.md` |
| 7 | My integration stopped syncing | `troubleshooting/integration-stopped.md` |

Every one of these is written from a fact that already exists in the repository as
an aside on a feature page. This section is a **re-shaping** of owned knowledge,
not new research. Page 1 carries the four-branch empty-list diagnostic (memlog
L94); page 7 carries the seven-branch runbook (L114).

**11 — Trust** (`parent: Trust`)

| # | Title | File |
|---|---|---|
| 1 | Docs health | `docs-health.md` |
| 2 | Docs baseline | `docs-baseline.md` |

`/docs-health` is the governance page (memlog L112): what `rake check` asserts,
when it last ran green, which pages carry a `TODO(owner):` and who owns it.
`/docs-baseline` is the measured starting state — page count, word count, image
count, broken-link count at the moment the harness went in — so that improvement
is demonstrable rather than asserted.

### Out of the nav, into the footer

Memlog L98. Four pages take `nav_exclude: true` and are reachable from a new
`_includes/footer_custom.html` on every page:

`request-new-feature.md` (today's `nav_order: 0`) · `is-it-working.md` ·
`privacy-policy.md` · `tos.md`

These are real pages that real readers occasionally need. They are not part of
the reading path. The footer is the correct affordance and it costs zero nav
slots. `trust.md` links to `is-it-working.md` in prose; `support.md` links to
`request-new-feature.md`.

### Non-page outputs

Produced by `layout: null` + `permalink:`, therefore invisible to the nav and to
this IA, but part of the URL surface:

`/404.html` (router with search — memlog L66/L89) · `/llms.txt` · `/llms-full.txt`
· `/fixtures/v1/**.json` · `/plane-status.json` · `/robots.txt` · `/sitemap.xml`

### Assertions — the whole IA in `script/check.rb`

`check.rb` reads front matter from every published `.md` and fails the build on
any of:

1. `nav_order` is absent on a page that is not `nav_exclude: true`.
2. `nav_order` is not an integer. **This kills the float shims permanently.**
3. Two sibling pages (same `parent`, or both root-level) share a `nav_order`. *Catches F5.*
4. A sibling group's `nav_order` values are not `1..N` contiguous. *Catches the unused `5`.*
5. A page declares `parent: X` and no page with `title: X` also declares `has_children: true`. *Catches F9's inverse.*
6. A page declares `has_children: true` and no page declares it as `parent`.
7. Two pages share a `title`. just-the-docs resolves `parent` by title; a duplicate silently mis-nests.
8. Any of the four footer pages lacks `nav_exclude: true`, or `_includes/footer_custom.html` fails to link all four.
9. Root-level `nav_order` count is not exactly 11 without a matching edit to this document. *Growth is allowed; silent growth is not.*

## Voice and Tone

Microcopy rules. Brand voice is DESIGN.md § Brand & Style.

**Say what happened, when, and where it came from.** The site's core failure is
not tone, it is unfalsifiability: `faq.md:26` states `£400/€490/$550` and
`faq.md:51` sells phone numbers at `£49/month for 100`, while
`features/find-phone-numbers.md:12` says phones come from the customer's own
LeadMagic key. Both cannot be true. Neither is dated. Neither is sourced.

- **Titles are the reader's words.** "My search returned no results," not
  "Result set diagnostics." Symptom before subsystem. This is also what makes the
  page findable by search — the query and the title are the same sentence.
- **Second person, present tense, active voice.** "Open Settings, then paste your
  key." Not "the key should then be pasted."
- **No unsourced number, ever.** Where a figure is real but not derivable from
  this repository, the page ships the render mechanism plus a
  `TODO(owner): <what is needed>` marker in `_data/`, and `script/check.rb` lists
  it on `/docs-health`. A missing number that is *visibly* missing is honest. An
  invented one is the failure mode this whole workstream exists to prevent.
- **Nothing may imply a live sandbox exists.** No page contains a string
  suggesting an issued key, a public base URL, or a hosted sandbox. Vale deny
  rule; the examples are `prism` against the checked-in fixtures.
- **British-English spelling, `£` first** where currency appears, matching the
  existing corpus. `script/check.rb` asserts currency-symbol consistency (memlog L97).
- **Fix `faq.md:51`'s "propsects."** Vale's spelling pass catches it and will keep
  catching its successors.

**Assertions:** Vale styles under `styles/SignalsAPI/` — `Symptom.Titles`
(troubleshooting titles must be first person and contain a verb),
`NoLiveSandbox` (deny list), `Passive`, `Spelling`, `SecondPerson`,
`BacktickProse` (DESIGN.md § Typography). `script/check.rb` — `TODO(owner):`
inventory, currency consistency.

## Component Patterns

Behaviour only; visual specs are DESIGN.md § Components.

**Router page.** A page whose job is to send the reader somewhere else within one
screen. Memlog L88/L96/L120. It must contain: a one-sentence statement of what
lives below it, then a list where every entry is `**[Title](url)** — one clause
saying who it is for`. It must not contain a pitch, a testimonial, or a booking
CTA. `index.md` today is 325 words of pitch with **zero links into the docs**,
closing on "Which side do you want to be on in 12 months?" — the exact opposite
of this pattern.

**Field table.** Replaces a screenshot. Columns: Field · What it does · Example.
This is the sanctioned fix for the eight 2024-era GitBook screenshots that depict
a UI the app no longer has — and specifically for
`remove-duplicate-signals.md` and `find-decision-makers.md`, where the entire
instructional payload sits inside an image with empty alt text. Text is
diffable, greppable, and readable by an agent. Pixels are none of those.

**Click path.** The text form of a UI walkthrough: `Settings → Integrations → Add
provider`. Arrows, monospace segments, no image. Survives a UI restyle;
a screenshot does not.

**Evidence callout.** A claim about the running product carries `verified_on` and
`owner` front matter (memlog L84) and renders a callout stating the date. Stale
means older than the threshold in `_data/`; `/docs-health` lists them.

**Pipeline strip.** Memlog L82. A page declares `stage: <id>`; an include renders
a "you are here" strip across the pipeline stages defined in
`_data/pipeline.yml`. **Assertion:** `check.rb` fails if a `stage:` value is not
a key in `_data/pipeline.yml`.

**Chooser include.** Memlog L95. A decision table — "if you want X, use Y" —
used on `apis/index.md` and on the Clay page. It is a table, not a wizard;
nothing is interactive.

**Search aliases.** Memlog L87. A page declares `search_aliases: [...]` listing
the words a reader would actually type. These feed the existing lunr index.
**Assertion:** every `page_type: symptom` page declares a non-empty
`search_aliases` array.

## State Patterns

A static site still has states. Five, and each has an owner.

| State | Where the reader meets it | Behaviour |
|---|---|---|
| **Not found** | `/404.html` | A router, not an apology. The search box, the eleven top-level destinations, and a link to `request-new-feature.md`. Memlog L66/L89. Client-side only — no logging, nothing POSTs. |
| **Search returned nothing** | Theme search dropdown | The theme's own empty state, plus `search_aliases` coverage on symptom pages so the common queries land. Zero-result logging is out of scope: it requires a backend. |
| **Fact not yet sourced** | Any page | `TODO(owner): <what is needed>` in `_data/`, rendered as a visible callout, listed on `/docs-health`. Never a placeholder number, never a blank. |
| **Fact gone stale** | Any page with `verified_on` | Rendered date in a callout; `/docs-health` lists everything past threshold. The page still serves — a dated fact beats a deleted one. |
| **Page removed** | Any old URL | Only ever via `jekyll-redirect-from` in the same commit as the deletion. There is no other permitted way for a URL to stop working. |

## Interaction Primitives

Four. There are no others, by constraint.

1. **Follow a link.** Internal links are relative and end in a trailing slash where the target is a directory index. html-proofer is the gate and it runs with `--disable-external` on the PR path so a third-party outage cannot redden an unrelated PR; the full external sweep runs nightly via lychee.
2. **Search.** Theme lunr, client-side, index already at `assets/js/search-data.json`. Fed by `search_aliases`.
3. **Expand a nav section.** Theme behaviour, driven by the front matter above.
4. **Copy a code block.** Theme behaviour.

**Not permitted, at all:** anything that fetches at page-view time, anything that
POSTs, live counters, Run buttons, embedded consoles, analytics, feedback
collectors, zero-result logging, service workers. Client-side JavaScript reading
data already in the repository is permitted — that is what the lunr index is.
GitHub-issue-prefill links are the sanctioned substitute for every "let the
reader tell us" idea: memlog L301, *"No backend — the issue body is the log."*

## Accessibility Floor

Deliberately narrow, entirely automated, and honest about what it does not cover.

- **Every image has meaningful alt text.** 62 of 70 PNGs currently have empty
  alt. html-proofer's alt-text assertion is the gate and it is non-negotiable.
  Where the image was carrying the instruction, the fix is the field table and
  the click path, not a caption.
- **Contrast** is one constant asserted in `script/check.rb`: `{colors.text}` on
  `{colors.bg}` at or above 4.5:1, computed in plain Ruby from the two hex values
  read out of `_sass/color_schemes/signalsapi.scss`.
- **Heading order** is asserted by `check.rb` — no level skipped, exactly one H1
  per page (Jekyll renders `title` as the H1, so page bodies start at H2).
- **Link text is meaningful.** Vale rule: deny "click here," "read more," "this
  link."
- **Keyboard and focus** are the theme's. The focus ring exists in
  `custom.scss`; it is not overridden.
- **Not covered, by decision:** pa11y-ci and axe are rejected. They need a
  headless browser and a node toolchain in a Ruby CI job and they fail
  nondeterministically. The floor above is asserted on every build, which is
  worth more than a comprehensive audit that gets disabled after its third false
  positive.

## Key Flows

Three protagonists, three entry paths, every landing page named.

### Flow 1 — Priya sets up her first search

Priya runs a six-person recruitment agency placing warehouse and logistics staff.
She signed up twenty minutes ago. She has a browser tab open and no patience.

1. Lands on **`/`** — the router. One sentence on what SignalsAPI does, then three doors: *I want to find leads* · *I want to call the API* · *I'm an AI agent*. She takes the first.
2. **`/quick-start/`** — the shared five-minute path: what a signal is, what a search is, what she will have at the end.
3. **`/quick-start/operator/`** — the operator fork. Create a search, set a location filter, run it.
4. She runs it and gets **nothing back.** *This is the climax beat, and it is where today's site loses her.* Today there is no page for this; the nearest fact is an aside on a feature page she has no reason to open.
5. The empty state on her results points her to **`/troubleshooting/empty-results/`** — "My search returned no results" — the four-branch diagnostic: filters too narrow, location string unmatched, work-arrangement filter excluding, signal window too short. Each branch names the exact control and links the feature page that owns it.
6. She widens the location filter, re-runs, gets 43 companies.
7. From there, **`/concepts/anatomy-of-a-lead/`** tells her what each field in the row means, field by field, on one real record — so the 43 rows become 43 decisions instead of 43 unknowns.

She never opened the Features section. That is correct: Features is a reference
shelf, not a path.

### Flow 2 — Dan wires the API into his ATS

Dan is the only engineer at a mid-size staffing firm. He has an API key, a
Postman window, and about ninety minutes before another meeting.

1. Lands on **`/`** from a Google result, takes door two.
2. **`/quick-start/developer/`** — auth, the first request, the shape of the response. Every fence declares its language; every example is `curl` he can paste.
3. **`/apis/`** — the router, with the chooser table: *REST if you own the loop · MCP if an agent owns the loop · Clay if your enrichment already lives there.* He is the first case.
4. **`/features/api-access/`** — endpoints and parameters. Reached under the **APIs** nav heading; the URL still says `features/` and he does not notice or care.
5. **`/limits/`** — rate limits and pagination, before he writes the loop rather than after it 429s. *This is the climax beat:* today this page does not exist, and the number that belongs on it is not sourceable from this repository. It ships with the table rendered from `_data/` and a `TODO(owner):` marker in the empty cell, listed on `/docs-health`. **He learns what he does not know, which is strictly better than learning a wrong number.**
6. **`/troubleshooting/api-auth/`** when his first call returns 403 — key scope, header name, the trailing-slash gotcha.
7. **`/whats-new/`** to subscribe his brain to changes. It has been dead since 2025-04-09 and is the only record of several shipped features; the API access and agent-data-plane launches shipped with docs and no entry.

### Flow 3 — Atlas, an AI agent, reads the corpus as a tool

Atlas is a coding agent running inside a customer's IDE. It was told: *"integrate
SignalsAPI."* It has no eyes, no browser, and no tolerance for a screenshot.

1. Fetches **`/llms.txt`** — the map: what this site is, the eleven sections, the URL of every page, one clause each.
2. Fetches **`/llms-full.txt`** — the whole corpus as text, in one request, in reading order.
3. Needs the contract, not the prose: fetches **`/openapi.yaml`**, validated by Spectral in `rake check`, so what it reads is what CI proved.
4. Needs a response to code against without a key it does not have: fetches **`/fixtures/v1/*.json`** — real-shaped, checked-in, curl-verifiable, served from the docs origin. *This is the climax beat.* The rejected alternative was a service worker that intercepts fetches so the browser demo passes — which would mean **the printed `curl` fails in the terminal the reader pastes it into.** A demo that lies about the artifact next to it is worse than no demo. Fixture URLs on the docs origin achieve the same goal honestly and CI can `curl` them.
5. Reads **`/features/agent-data-plane-mcp/`** for the connect snippet, and gets the honest answer: the source and the snippet are here, the hosted server is not. Hosting is out of scope and the page says so rather than implying otherwise.
6. Checks **`/plane-status.json`** for the machine-readable statement of what is contract and what is aspiration.

At no point does Atlas encounter a page whose instruction lives inside an image,
a number with no source, or a string implying a live sandbox key exists. That is
the whole design goal, and every one of those three is a `rake check` assertion.

## Page-Shape Conventions

Five page types. Every published `.md` declares exactly one `page_type`. Each type
has a front-matter contract and a required H2 skeleton, and **each rule below is
stated as the assertion that enforces it** — a convention `script/check.rb` or
Vale cannot assert does not belong in this document.

### Universal contract — every published page

| Key | Rule |
|---|---|
| `title` | Required. Unique site-wide. |
| `layout` | Required. `default` for every page except `index.md`, which is the only permitted `layout: home`. *Fixes F6.* |
| `nav_order` | Required integer unless `nav_exclude: true`. |
| `description` | Required, 50–160 characters, unique site-wide. *Fixes F7 — today all 28 pages inherit the single `_config.yml` description.* |
| `page_type` | Required. One of `router`, `concept`, `task`, `symptom`, `reference`. |
| `parent` | Required if not top-level. Must match a `title` whose page declares `has_children: true`. |

`strict_front_matter: true` in `_config.yml` fails the build on malformed YAML.
`script/check.rb` asserts every row above, plus: exactly one H1 per page, no
skipped heading level, every code fence carries a language, no `![]()` or `<img>`
with empty alt.

### `page_type: router`

*Pages:* `index.md`, `quick-start.md`, `concepts/index.md`, `features/index.md`,
`apis/index.md`, `troubleshooting/index.md`, `trust.md`, `404.html`.

- **Front matter adds:** `has_children: true` (except `404.html`).
- **Skeleton:** an intro paragraph, then `## Where to go`, then optionally `## Related`.
- **Assertion:** contains at least three internal links; contains no `<img>`; body under 250 words; contains no external link to a booking or scheduling host. *That last clause is aimed squarely at `index.md`'s current `signals.fillout.com/meet` CTA.*

### `page_type: concept`

*Pages:* `concepts/*`, `how-it-works.md`.

- **Front matter adds:** `search_aliases` (optional), `stage` (optional), `verified_on` + `owner` when the page states a fact about the running product.
- **Skeleton:** `## What it is` · `## Why it matters` · `## How it fits the pipeline` · `## Related`.
- **Assertion:** all four H2s present in that order; no `##` heading in the imperative mood (Vale — a concept page that starts giving instructions is a task page wearing the wrong `page_type`).

### `page_type: task`

*Pages:* `quick-start/*`, the fifteen `features/*` how-to pages.

- **Front matter adds:** `stage` (optional).
- **Skeleton:** `## Before you start` · `## Steps` · `## Check it worked` · `## If it didn't`.
- **Assertion:** all four H2s present in order; `## Steps` contains an ordered list; `## If it didn't` contains at least one link to a `/troubleshooting/` page. **Every task page therefore has a named failure path — this is the single convention that most directly prevents Priya's step 4 from being a dead end.**

### `page_type: symptom`

*Pages:* `troubleshooting/*`.

- **Front matter adds:** `search_aliases` — **required, non-empty.**
- **Skeleton:** `## What you're seeing` · `## Most likely cause` · `## Check this first` · `## Other causes` · `## Still stuck`.
- **Assertion:** all five H2s in order; `search_aliases` present and non-empty; `title` is first person and contains a verb (Vale `Symptom.Titles`); `## Still stuck` links `support.md`.

### `page_type: reference`

*Pages:* `limits.md`, `pricing.md`, `faq.md`, `support.md`, `docs-health.md`, `docs-baseline.md`, the five API pages, `whats-new/index.md`.

- **Front matter adds:** `verified_on` + `owner` — **required.** A reference page makes claims about the product; an undated claim is the defect class this overhaul exists to eliminate.
- **Skeleton:** free, but every table renders from `_data/` where the same values appear on more than one page — the DRY rule that stops `faq.md` and `find-phone-numbers.md` from contradicting each other again.
- **Assertion:** `verified_on` present and parseable as a date; any figure that would be published without a `_data/` source is a `TODO(owner):` marker instead, inventoried on `/docs-health`; currency symbols consistent site-wide; Vale `NoLiveSandbox` deny list clean.

## Open Questions

1. Fifteen Features children need a reading order. Alphabetical is the default and is wrong; the correct order is the pipeline order, which needs `_data/pipeline.yml` to exist first.
2. `faq.md` overlaps `pricing.md`, `limits.md`, and `support.md` once those exist. The contradictory pricing content at `faq.md:26` and `faq.md:51` must resolve to exactly one home. Deferring the split is safe; deferring the contradiction is not.
3. The staleness threshold for `verified_on` is a policy choice with no defensible default. `TODO(owner):` until set.
4. `whats-new/` holds 53 of the site's 70 PNGs (~1.9 MB). Whether the changelog migrates to `_data/` (memlog L75) or is frozen and superseded is unresolved; either way it is not a nav problem.
